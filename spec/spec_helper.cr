require "spec"
require "../src/medup"

def fixtures(name)
  raw = File.read(File.join("spec", "fixtures", name))
  JSON.parse(raw)
end

def post_fixture
  data = fixtures("post_response.json")
  data["payload"]["value"].to_json
end

def post_without_name_fixture
  data = fixtures("post_without_name_response.json")
  data["payload"]["value"].to_json
end

def post_without_dropimage_fixture
  data = fixtures("post_without_dropimage.json")
  data["payload"]["value"].to_json
end

def user_fixture
  data = fixtures("post_response.json")
  creator_id = data["payload"]["value"]["creatorId"].as_s
  data["payload"]["references"]["User"][creator_id].to_json
end
