require "spec"
require "webmock"

require "../src/medup"

Spec.before_suite do
  io = IO::Memory.new
  Base64.decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=", io)
  WebMock.stub(:get, "https://miro.medium.com/0*FbFs8aNmqNLKw4BM")
    .to_return(
      body: io.to_s,
      headers: HTTP::Headers{
        "Content-Type"   => "image/png",
        "Content-length" => "1",
      }
    )
  WebMock.stub(:get, "https://miro.medium.com/1*NVLl4oVmMQtumKL-DVV1rA.png")
    .to_return(body: "some binary content", headers: HTTP::Headers{"Content-Type" => "image/png"})

  WebMock.stub(:get, "https://medium.com/media/e7722acf2*886364130e03d2c7ad29de7")
    .to_return(body: "<div>Iframe example</div>", headers: HTTP::Headers{"Content-Type" => "text/html"})
  WebMock.stub(:get, "https://medium.com/media/ab24f0b378f797307fddc32f10a99685")
    .to_return(body: "<div>Iframe example</div>", headers: HTTP::Headers{"Content-Type" => "text/html"})
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

def logger
  Logger.new(STDOUT, level: Logger::FATAL)
end
