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
          if @iframe.nil?
            "<!-- Missing iframe -->"
          else
            frame = @iframe.not_nil!
            "<iframe src=\"./assets/#{frame.mediaResourceId}.html\"></iframe>"
            # Support Frame mode with inline content. Github does not support it.
            #"<frame>#{frame.get}</frame>"
          end
        when 13
          "### #{@text}"
        when 14
          "#{@mixtapeMetadata.try &.href}"
        else
          raise "Unknown paragraph type #{@type} with text #{@text}"
        end
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
