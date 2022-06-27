require "./options"

module Medup
  struct Settings
    DEFAULT_ASSETS_DIR_NAME  = "assets"
    DEFAULT_POSTS_PATH       = "./posts"
    DEFAULT_ASSETS_BASE_PATH = "./assets"

    PLATFORM_DEVTO   = "devto"
    PLATFORM_MEDIUM  = "medium"
    DEFAULT_PLATFORM = PLATFORM_MEDIUM
    PLATFORMS        = [PLATFORM_MEDIUM, PLATFORM_DEVTO]

    property platform : String = DEFAULT_PLATFORM
    property medium_token : String?
    property github_api_token : String?
    property posts_dist : String = DEFAULT_POSTS_PATH
    setter assets_dist : String?
    property assets_base_path : String = DEFAULT_ASSETS_BASE_PATH
    property options : Array(::Medup::Options) = Array(Medup::Options).new

    def initialize
    end

    def valid?
      PLATFORMS.includes?(@platform)
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

    def assets_dist : String
      @assets_dist ||= File.join(@posts_dist, DEFAULT_ASSETS_DIR_NAME)
    end
  end
end
