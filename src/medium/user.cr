require "json_mapping"

module Medium
  class User
    JSON.mapping(
      userId: String,
      name: String,
      username: String
    )
  end
end
