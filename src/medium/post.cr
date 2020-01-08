require "./post/*"

module Medium
  class Post
    property url : String = ""

    JSON.mapping(
      title: String,
      slug: String,
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
      tags: #{tags}\n\
      ---\n\n"
      result +
        @content.bodyModel.paragraphs.map(&.to_md).join("\n\n")
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
  end

  class PostContent
    JSON.mapping(
      subtitle: String,
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
