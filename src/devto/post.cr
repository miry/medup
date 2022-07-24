require "yaml"

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
    property tags : Array(String) = [] of String

    def to_md
      result = md_header
      assets = Hash(String, String).new
      footer = "\n"

      result += md_cover_image(assets)

      result += "# " + @title + "\n\n"

      content = md_content(assets)
      result += content + "\n\n"

      if !@ctx.settings.assets_image?
        footer += assets.map do |asset_name, asset_content|
          "[#{asset_name}]: #{asset_content}"
        end.join("\n")
      end

      result += footer

      return result, assets
    end

    def md_header
      header = {
        "url"           => @url,
        "canonical_url" => @canonical_url,
        "title"         => @title,
        "slug"          => @slug,
        "description"   => @description,
        "tags"          => @tags,
      }

      header.to_yaml + "---\n\n"
    end

    def md_cover_image(assets)
      return "" if @cover_image == ""

      assets_base_path = @ctx.settings.assets_base_path
      asset_body, asset_type, asset_name = download_image("cover_image", @cover_image)
      result = "![Cover image]"

      if @ctx.settings.assets_image?
        assets[asset_name] = asset_body
        result += "(#{assets_base_path}/#{asset_name})"
      else
        asset_id = "img_ref_cover_image"
        assets[asset_id] = "data:#{asset_type};base64," + \
          Base64.strict_encode(asset_body)

        result += "[#{asset_id}]"
      end

      result + "\n\n"
    end

    def md_content(assets) : String
      assets_base_path = @ctx.settings.assets_base_path
      @body_markdown.gsub(/(?<image_start>!\[[^\]]*\])\((?<src>[^\)]*)\)/) do |md_img_tag, match|
        src = match["src"]
        uri = URI.parse src
        asset_name = File.basename(uri.path)
        asset_body, asset_type, asset_name = download_image(asset_name, src)

        result = match["image_start"]
        if @ctx.settings.assets_image?
          assets[asset_name] = asset_body
          result += "(#{assets_base_path}/#{asset_name})"
        else
          asset_id = "img_ref_" + asset_name.gsub(".", "_")
          assets[asset_id] = "data:#{asset_type};base64," + \
            Base64.strict_encode(asset_body)
          result += "[" + asset_id + "]"
        end

        result
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
