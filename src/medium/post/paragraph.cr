module Medium
  class Post
    class Paragraph
      JSON.mapping(
        {
          name:            String,
          type:            Int64,
          text:            String,
          markups:         Array(ParagraphMarkup),
          metadata:        ParagraphMetadata?,
          layout:          Int64?,
          hasDropCap:      Bool?,
          iframe:          Iframe?,
          mixtapeMetadata: MixtapeMetadata?,
          href:            String?,
          alignment:       Int64?,
        },
        strict: true
      )

      def to_md
        case @type
        when 1
          markup
        when 2
          "# #{markup}"
        when 3
          "# #{markup}"
        when 4
          # "[#{@text}](https://miro.medium.com/#{metadata.try(&.id)})"
          if @href
            "[![#{@text}](./assets/#{metadata.try(&.id)})](#{@href})"
          else
            "![#{@text}](./assets/#{metadata.try(&.id)})"
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
            "<iframe src=\"./assets/#{frame.mediaResourceId}.html\"></iframe>"
            # Support Frame mode with inline content. Github does not support it.
            # "<frame>#{frame.get}</frame>"
          end
        when 13
          "### #{markup}"
        when 14
          "#{@mixtapeMetadata.try &.href}"
        else
          raise "Unknown paragraph type #{@type} with text #{@text}"
        end
      end

      def markup
        open_elements = {} of Int64 => Array(ParagraphMarkup)
        close_elements = {} of Int64 => Array(ParagraphMarkup)

        last_marked_pos = 0

        result : String = ""
        @markups.each do |m|
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
        @text.each_char_with_index do |c, i|
          if close_elements.has_key?(i)
            close_elements[i].each do |m|
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

          if open_elements.has_key?(i)
            open_elements[i].each do |m|
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

          result += c
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
          mediaResourceId: String
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
    end
  end
end
