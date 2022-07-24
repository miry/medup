require "json_mapping"
require "yaml"

require "./post/*"

module Medium
  class Post
    property ctx : ::Medup::Context = ::Medup::Context.new
    property user : Medium::User?

    JSON.mapping(
      title: String,
      slug: String,
      mediumUrl: String,
      canonicalUrl: String,
      createdAt: Int64,
      updatedAt: Int64,
      content: PostContent,
      virtuals: PostVirtuals
    )

    def format(ext)
      case ext
      when "json"
        to_pretty_json
      when "md"
        to_md
      else
        raise "Unknown render format #{ext}"
      end
    end

    def to_md
      header = {
        "url"           => mediumUrl,
        "canonical_url" => canonicalUrl,
        "title"         => @title,
        "subtitle"      => subtitle,
        "slug"          => @slug,
        "description"   => seo_description,
        "tags"          => tags,
      }
      user = @user
      if !user.nil?
        header["author"] = user.name
        header["username"] = user.username
      end

      result = header.to_yaml + "---\n\n"

      assets = Hash(String, String).new
      footer = "\n"

      @content.bodyModel.paragraphs.map do |paragraph|
        content, asset_name, asset_content = paragraph.to_md(@ctx)
        result += content + "\n\n"
        if !asset_content.empty?
          if paragraph.type == 11 ||
             (paragraph.type == 4 && @ctx.settings.assets_image?)
            assets[asset_name] = asset_content
          else
            footer += asset_content + "\n"
          end
        end
      end

      result += footer

      return result, assets
    end

    def to_pretty_json
      @content.to_pretty_json
    end

    def seo_description
      @content.metaDescription || ""
    end

    def subtitle
      @content.subtitle || ""
    end

    def tags : Array(String)
      @virtuals.tags.map &.slug
    end

    def created_at
      Time.unix_ms(@createdAt)
    end
  end

  class PostContent
    JSON.mapping(
      subtitle: String?,
      metaDescription: String?,
      bodyModel: PostBodyModel
    )
  end

  class PostVirtuals
    JSON.mapping(
      tags: Array(Post::Tag)
    )
  end

  class PostBodyModel
    JSON.mapping(
      paragraphs: Array(Post::Paragraph)
    )
  end

  class ParagraphMetadata
    JSON.mapping(
      id: String
    )
  end
end
