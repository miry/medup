require "json_mapping"
require "zaru_crystal/zaru"

require "logger"

module Medium
  class Post
    class Paragraph
      @logger : Logger = Logger.new(STDOUT)

      JSON.mapping(
        {
          name:            String?,
          type:            Int64,
          text:            String,
          markups:         Array(ParagraphMarkup)?,
          metadata:        ParagraphMetadata?,
          layout:          Int64?,
          hasDropCap:      Bool?,
          dropCapImage:    DropCapImage?,
          iframe:          Iframe?,
          mixtapeMetadata: MixtapeMetadata?,
          href:            String?,
          alignment:       Int64?,
        },
        strict: true
      )

      def to_md(
        options : Array(Medup::Options) = Array(Medup::Options).new,
        logger : Logger = Logger.new(STDOUT)
      ) : Tuple(String, String, String)
        @logger = logger
        content : String = ""
        assets = ""
        asset_name = ""
        content = case @type
                  when 1
                    markup
                  when 2
                    "# #{markup}"
                  when 3
                    "# #{markup}"
                  when 4
                    m = metadata
                    if !m.nil? && !m.id.nil?
                      asset_body, asset_type, asset_name = download_image(m.id || "")
                      asset_id = Base64.strict_encode(m.id)
                      if options.includes?(Medup::Options::ASSETS_IMAGE)
                        assets = asset_body
                        if @href
                          "[![#{@text}](./assets/#{asset_name})](#{@href})"
                        else
                          "![#{@text}](./assets/#{asset_name})"
                        end
                      else
                        assets = "[image_ref_#{asset_id}]: data:#{asset_type};base64,"
                        img = "![#{@text}][image_ref_#{asset_id}]"
                        assets += Base64.strict_encode(asset_body)
                        if @href
                          img = "[#{img}](#{@href})"
                        end
                        img
                      end
                    else
                      ""
                    end
                  when 6
                    "> #{markup}"
                  when 7
                    ">> #{markup}"
                  when 8
                    "```\n#{@text}\n```"
                  when 9
                    "* #{markup}"
                  when 10
                    "1. #{markup}"
                  when 11
                    if @iframe.nil?
                      "<!-- Missing iframe -->"
                    else
                      frame = @iframe.not_nil!
                      result = ""

                      media_content, media_type = download(frame.mediaResourceId)
                      if media_content.includes?(%{<script src="https://gist.github.com/})
                        result = process_gist_content(media_content)
                      elsif media_content.includes?("schema=youtube")
                        result = process_youtube_content(media_content)
                      elsif media_content.includes?("https://twitter.com")
                        result = process_twitter_content(media_content)
                      end

                      if result.empty?
                        asset_id = Zaru.sanitize!(frame.mediaResourceId)
                        asset_name = "#{asset_id}.html"
                        asset_body, _content_type = download(frame.mediaResourceId)
                        assets = asset_body
                        result = "<iframe src=\"./assets/#{asset_id}.html\"></iframe>"
                        markup_body = markup.strip
                        if !markup_body.empty?
                          result += "\n#{markup_body}"
                        end
                      end

                      result
                    end
                  when 13
                    "### #{markup}"
                  when 14
                    "#{@mixtapeMetadata.try &.href}"
                  when 15
                    ""
                  else
                    raise "Unknown paragraph type #{@type} with text #{@text}"
                  end
        return content, asset_name, assets
      end

      def download(name : String)
        src = "https://medium.com/media/#{name}"
        response = HTTP::Client.get(src)
        @logger.info "GET #{src} => #{response.status_code} #{response.status_message}"
        @logger.info 12, response.headers.to_s
        @logger.info 12, response.body
        return response.body, response.content_type
      end

      def download_image(name : String)
        src = "https://miro.medium.com/#{name}"
        response = HTTP::Client.get(src)
        @logger.debug "GET #{src} => #{response.status_code} #{response.status_message}"
        @logger.info 12, response.headers.to_s
        filename = name
        ext = File.extname(filename)
        if ext == ""
          mt = response.mime_type
          if !mt.nil? && !mt.sub_type.nil?
            filename += "." if filename[-1] != '.'
            filename += mt.sub_type.not_nil!
          end
        end
        return response.body, response.content_type, filename
      end

      def process_youtube_content(content : String) : String
        @logger.debug 7, "Processing youtube element"
        m = content.match(/\<iframe[^\>]*widgets\/media\.html\?.*(&amp;)?url=(?<url>[^&;]*)&amp;/)
        return "" if m.nil?
        m = m.not_nil!
        url = URI.decode(m["url"]).sub("http://", "https://")
        id = url[/v=[^&]+/][2..]
        thumbnail_url = "https://img.youtube.com/vi/#{id}/hqdefault.jpg"
        # TODO: Download thumbnails in same way as images with `download_image`
        "[![Youtube](#{thumbnail_url})](#{url})"
      end

      def fetch_gist(id : String?)
        return nil if id.nil?

        src = "https://api.github.com/gists/#{id}"
        response : HTTP::Client::Response? = nil

        3.times do
          response = HTTP::Client.get(src)
          @logger.info "GET #{src} => #{response.status_code} #{response.status_message}"
          @logger.info 12, response.headers.to_s
          @logger.info 12, response.body
          break if response.status_code != 403
          response = nil
          sleep 3 # 3 seconds
        end

        return nil if response.nil?

        result = JSON.parse(response.body).try(&.["files"]).try(&.as_h)
        return nil if result.nil?

        return result.map { |_, spec| spec.as_h }
      end

      def process_gist_content(content : String) : String
        @logger.debug 7, "Processing gist element"
        m = content.match(/\<script src=\"https:\/\/gist\.github\.com\/[^\/]*\/(?<id>[^"]*).js/)
        return "" if m.nil?

        gists = fetch_gist(m["id"])

        return "" if gists.nil?

        return gists.map do |gist|
          "```\n#{gist["content"]}\n```\n" +
            "> *[#{gist["filename"]} view raw](#{gist["raw_url"]})*"
        end.join("\n")
      end

      def process_twitter_content(content : String) : String
        @logger.debug 7, "Processing twitter element"
        m = content.match(/<meta[^>]*name="description"[^>]*>/m)
        return "" if m.nil?

        m = m[0].match(/content="(?<tweet>[^"]*)"/m)
        return "" if m.nil? || m["tweet"].empty?

        result = "> #{m["tweet"]}"

        m = content.match(/<blockquote[^>]*class="twitter-tweet"[^>]*>(?<quote>.*)<\/blockquote>/m)
        return result if m.nil? || m["quote"].empty?
        result + "\n> " + m["quote"]
      end

      def markup
        open_elements = {} of Int64 => Array(ParagraphMarkup)
        close_elements = {} of Int64 => Array(ParagraphMarkup)

        last_marked_pos = 0

        result : String = ""
        _markups = @markups
        return result if _markups.nil?
        _markups.each do |m|
          if open_elements.has_key?(m.start)
            open_elements[m.start] << m
          else
            open_elements[m.start] = [m] of ParagraphMarkup
          end

          if close_elements.has_key?(m.end)
            close_elements[m.end].insert(0, m)
          else
            close_elements[m.end] = [m] of ParagraphMarkup
          end
        end

        @text += " "
        char_index = 0
        # Grapheme is an experimental feature from Crystal to return symbols as
        # rendered, instead of static width bytes. It helpes to easy identify
        # emoji symbols chain.
        @text.each_grapheme do |symbol|
          if close_elements.has_key?(char_index)
            close_elements[char_index].each do |m|
              case m.type
              when 1 # bold
                result += "**"
              when 2 # italic
                result += "*"
              when 3 # link
                href = m.href.nil? ? "" : m.href.not_nil!
                result += "](#{href})"
              when 10 # code inline
                result += "`"
              else
                raise "Unknown markup type #{m.type} with text #{@text[m.start...m.end]}"
              end
            end
          end

          if open_elements.has_key?(char_index)
            open_elements[char_index].each do |m|
              case m.type
              when 1 # bold
                result += "**"
              when 2 # italic
                result += "*"
              when 3 # link
                result += "["
              when 10 # code inline
                result += "`"
              else
                raise "Unknown markup type #{m.type} with text #{@text[m.start...m.end]}"
              end
            end
          end

          result += symbol.to_s
          # Medium count each emoji symbol as 4 bytes, when Crystal uses 2 bytes.
          char_index += symbol.size == 1 ? 1 : symbol.size * 2
        end

        result.rchop
      end

      class ParagraphMarkup
        JSON.mapping(
          type: Int64,
          start: Int64,
          "end": Int64,
          href: String?,
          title: String?,
          rel?: String?,
          anchorType: Int64?
        )
      end

      class Iframe
        getter content : String?

        JSON.mapping(
          mediaResourceId: String,
          thumbnailUrl: String?,
          iframeWidth: Int64?,
          iframeHeight: Int64?
        )

        def get
          @content ||= Medium::Client.default.media(mediaResourceId)
        end
      end

      class MixtapeMetadata
        JSON.mapping(
          mediaResourceId: String,
          href: String?
        )
      end

      class DropCapImage
        JSON.mapping(
          id: String,
          originalWidth: Int64,
          originalHeight: Int64
        )
      end
    end
  end
end
