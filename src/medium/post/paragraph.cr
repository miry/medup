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
        },
        strict: true
      )

      def to_md
        case @type
        when 1
          @text
        when 3
          "# #{@text}"
        when 4
          # "[#{@text}](https://miro.medium.com/#{metadata.try(&.id)})"
          if @href
            "[![#{@text}](./assets/#{metadata.try(&.id)})](#{@href})"
          else
            "![#{@text}](./assets/#{metadata.try(&.id)})"
          end
        when 6
          "> #{@text}"
        when 7
          ">> #{@text}"
        when 8
          "```\n#{@text}\n```"
        when 9
          "* #{@text}"
        when 10
          "1. #{@text}"
        when 11
          "Embeded content: iframe"
        when 13
          "### #{@text}"
        when 14
          "#{@mixtapeMetadata.try &.href}"
        else
          raise "Unknown paragraph type #{@type} with text #{@text}"
        end
      end

      class Iframe
        JSON.mapping(
          mediaResourceId: String
        )
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
