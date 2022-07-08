require "../medup/post"

module Devto
  class Post < ::Medup::Post
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    property title : String = ""
    property description : String = ""
    property url : String = ""
    property canonical_url : String = ""
    property cover_image : String = ""
    property body_markdown : String = ""
    property tag_list : String = ""

    def to_md
      result = md_header
      assets = Hash(String, String).new
      footer = "\n"

      result += md_cover_image(assets)

      result += "# " + @title + "\n"

      content = md_content(assets)
      result += content

      footer += assets.map do |asset_name, asset_content|
        "[#{asset_name}]: #{asset_content}"
      end.join("\n")

      result += footer

      return result, assets
    end

    def md_header
      result = "---\n\
        url: #{@url}\n\
        canonical_url: #{@canonical_url}\n\
        title: #{@title}\n\
        slug: #{@slug}\n\
        description: #{@description}\n\
        tags: #{@tag_list}\n\
        ---\n\n"
      result
    end

    def md_cover_image(assets)
      return "" if @cover_image == ""

      asset_id = "img_ref_cover_image"
      asset_body, asset_type, asset_name = download_image("cover_image", @cover_image)
      assets[asset_id] = "data:#{asset_type};base64," + \
        Base64.strict_encode(asset_body)

      "![Cover image][#{asset_id}]\n\n"
    end

    def md_content(assets) : String
      @body_markdown.gsub(/(?<image_start>!\[[^\]]*\])\((?<src>[^\)]*)\)/) do |md_img_tag, match|
        src = match["src"]
        uri = URI.parse src
        asset_name = File.basename(uri.path)
        asset_id = "img_ref_" + asset_name.gsub(".", "_")
        asset_body, asset_type, asset_name = download_image(asset_name, src)
        assets[asset_id] = "data:#{asset_type};base64," + \
          Base64.strict_encode(asset_body)
        match["image_start"] + "[" + asset_id + "]"
      end
    end

    def download_image(name : String, src : String)
      response = HTTP::Client.get(src)
      @ctx.logger.debug "GET #{src} => #{response.status_code} #{response.status_message}"
      @ctx.logger.info 12, response.headers.to_s
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
  end
end
