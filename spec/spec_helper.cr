require "spec"
require "webmock"

require "../src/medup"

Spec.before_suite do
  WebMock.stub(:get, "https://miro.medium.com/0*FbFs8aNmqNLKw4BM")
    .to_return(body: "some binary content")
  WebMock.stub(:get, "https://miro.medium.com/1*NVLl4oVmMQtumKL-DVV1rA.png")
    .to_return(body: "some binary content")
end

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
