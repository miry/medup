require "./post/*"

module Medium
  class Post
    JSON.mapping(
      title: String,
      slug: String,
      content: PostContent
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
      @content.bodyModel.paragraphs.map(&.to_md).join("\n")
    end

    def to_pretty_json
      @content.to_pretty_json
    end
  end

  class PostContent
    JSON.mapping(
      subtitle: String,
      metaDescription: String?,
      bodyModel: PostBodyModel
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

  class ParagraphMarkup
    JSON.mapping(
      type: Int64
    )
  end
end
