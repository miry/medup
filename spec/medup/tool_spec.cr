require "../spec_helper"

require "file_utils"

describe Medup::Tool do
  describe "initialization" do
    it { ::Medup::Tool.new }
  end

  describe "#backup" do
    it "detects missing articles" do
      subject = ::Medup::Tool.new
      expect_raises(Exception, "No articles to backup") do
        subject.backup
      end
    end

    it "detects devto article by url" do
      subject = ::Medup::Tool.new(articles: ["https://dev.to/something"])
      subject.backup
    end

    it "does not create posts folder" do
      FileUtils.rm_rf "posts"

      WebMock.stub(:get, "https://medium.com/@anonymous?format=json")
        .to_return(
          body: "." * 16 + %|{"payload":{"user":{"userId":"123123"}}}|,
          headers: HTTP::Headers{"Content-Type" => "text/json"}
        )

      payload = <<-JSON
      {
        "payload": {
          "streamItems": [
            {
              "itemType": "postPreview",
              "postPreview": {"postId": "postid"}
            }
          ]
        }
      }
      JSON
      WebMock.stub(:get, "https://medium.com/_/api/users/123123/profile/stream?format=json&limit=100&source=overview")
        .to_return(
          body: "." * 16 + payload,
          headers: HTTP::Headers{"Content-Type" => "text/json"}
        )

      WebMock.stub(:get, "https://medium.com/@anonymous/postid?format=json")
        .to_return(
          body: "." * 16 + File.read(File.join("spec", "fixtures", "post_response.json")),
          headers: HTTP::Headers{"Content-Type" => "text/json"}
        )

      settings = ::Medup::Settings.new
      settings.dry_run!
      ctx = ::Medup::Context.new(settings)
      subject = ::Medup::Tool.new(
        ctx: ctx,
        user: "anonymous"
      )

      subject.backup

      File.exists?("posts").should be_false
    end

    it "with devto and user" do
      WebMock.stub(:get, "https://dev.to/api/articles?username=miry&page=1&per_page=1000")
        .to_return(
          body: "[]",
          headers: HTTP::Headers{"Content-Type" => "text/json"}
        )

      settings = ::Medup::Settings.new
      settings.platform = ::Medup::Settings::PLATFORM_DEVTO
      ctx = ::Medup::Context.new(settings)
      subject = ::Medup::Tool.new(
        ctx: ctx,
        user: "miry"
      )

      expect_raises(Exception, "No articles to backup") do
        subject.backup
      end
    end
  end
end
