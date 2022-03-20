require "json_mapping"
require "./post/*"

module Medium
  class Post
    property url : String = ""
    property user : Medium::User?
    property options : Array(Medup::Options) = Array(Medup::Options).new

    JSON.mapping(
      title: String,
      slug: String,
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
      result = "---\n\
        url: #{@url}\n\
        title: #{@title}\n\
        subtitle: #{subtitle}\n\
        slug: #{@slug}\n\
        description: #{seo_description}\n\
        tags: #{tags}\n"

      unless @user.nil?
        user = @user.not_nil!
        result += "author: #{user.name}\n\
          username: #{user.username}\n"
      end

      result += "---\n\n"
      assets = "\n"
      @content.bodyModel.paragraphs.map do |paragraph|
        content, footer = paragraph.to_md(@options)
        result += content + "\n\n"
        assets += footer + "\n" unless footer.empty?
      end
      result + assets
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

    # Comma seprated list of tags
    def tags
      @virtuals.tags.join ",", &.slug
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
