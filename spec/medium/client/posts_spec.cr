require "../../spec_helper"

describe Medium::Client::Posts do
  describe "#normalize_urls" do
    it "extract id from url with medium host" do
      client = Medium::Client.new("", "", "", logger)
      urls = client.normalize_urls(["https://medium.com/notes-and-tips-in-full-stack-development/crystal-detects-emoji-symbols-in-string-b6759ab94625"])
      urls.should eq(["https://medium.com/@/b6759ab94625"])
    end

    it "keep custom domain url" do
      client = Medium::Client.new("", "", "", logger)
      urls = client.normalize_urls(["https://jtway.co/git-minimum-for-effective-project-development-841a0b865ef0"])
      urls.should eq(["https://jtway.co/git-minimum-for-effective-project-development-841a0b865ef0"])
    end
  end
end
