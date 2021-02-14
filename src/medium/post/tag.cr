require "json_mapping"

module Medium
  class Post
    class Tag
      JSON.mapping(
        slug: String
      )
    end
  end
end
