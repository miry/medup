require "../spec_helper"

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
