require "./options"

module Medup
  struct Settings
    property medium_token : String?
    property github_api_token : String?
    property options : Array(::Medup::Options) = Array(Medup::Options).new

    def initialize
    end

    def set_update_content!
      @options << ::Medup::Options::UPDATE_CONTENT
    end

    def update_content? : Bool
      @options.includes?(Medup::Options::UPDATE_CONTENT)
    end

    def set_assets_image!
      @options << ::Medup::Options::ASSETS_IMAGE
    end

    def assets_image? : Bool
      @options.includes? ::Medup::Options::ASSETS_IMAGE
    end
  end
end
