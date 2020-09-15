require "../../spec_helper"

describe Medium::Post::Paragraph do
  it "initialize" do
    subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 3, "text": "Modify binary files with VIM", "markups": []}})
    subject.name.should eq("d2a9")
    subject.text.should eq("Modify binary files with VIM")
    subject.type.should eq(3)
  end

  describe "#to_md" do
    it "should render header" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 3, "text": "Modify binary files with VIM", "markups": []}})
      subject.to_md[0].should eq("# Modify binary files with VIM")
    end

    it "renders blockquotes" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 6, "text": "TLDR text", "markups": []}})
      subject.to_md[0].should eq("> TLDR text")
    end

    it "renders blockquotes second style" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 7, "text": "TLDR text", "markups": []}})
      subject.to_md[0].should eq(">> TLDR text")
    end

    it "renders images" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 4, "text": "Photo", "layout": 3, "metadata":{"id":"0*FbFs8aNmqNLKw4BM"}, "markups": []}})
      content, assets = subject.to_md
      content.should eq("![Photo][image_ref_MCpGYkZzOGFObXFOTEt3NEJN]")
      assets.should match(/^\[image_ref_MCpGYkZzOGFObXFOTEt3NEJN\]:/)
    end

    it "render number list" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 10, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md[0].should eq("1. it should be cross distributive solution")
    end

    it "render unordered list" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 9, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md[0].should eq("* it should be cross distributive solution")
    end

    it "render text" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 1, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md[0].should eq("it should be cross distributive solution")
    end

    it "render title" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 2, "text": "render title with picture", "markups": [], "alignment": 2}})
      subject.to_md[0].should eq("# render title with picture")
    end

    it "render code block" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 8, "text": "puts hello", "markups": []}})
      subject.to_md[0].should eq("```\nputs hello\n```")
    end

    it "render small header" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 13, "text": "Help", "markups": []}})
      subject.to_md[0].should eq("### Help")
    end

    it "render link references" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 14, "text": "Socket::Addrinfo", "markups": [], "mixtapeMetadata": {"mediaResourceId": "7f3accd276b8655a927e5d50f276d49d","href":"https://crystal-lang.org/api/0.31.0/Socket/Addrinfo.html"}}})
      subject.to_md[0].should eq("https://crystal-lang.org/api/0.31.0/Socket/Addrinfo.html")
    end

    it "render image with link" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 4, "text": "", "layout": 3, "href": "https://asciinema.org/a/5diw0wwk6vbbovnqrk5sh1soy", "markups": [], "metadata":{"id": "1*NVLl4oVmMQtumKL-DVV1rA.png"}}})
      content, assets = subject.to_md
      content.should eq("[![][image_ref_MSpOVkxsNG9WbU1RdHVtS0wtRFZWMXJBLnBuZw==]](https://asciinema.org/a/5diw0wwk6vbbovnqrk5sh1soy)")
    end

    it "render iframe inline" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 11, "text": "", "markups": [], "iframe":{"mediaResourceId": "e7722acf2886364130e03d2c7ad29de7"}}})
      subject.to_md[0].should eq(%{<iframe src="./assets/e7722acf2886364130e03d2c7ad29de7.html"></iframe>})
    end

    it "renders inline code block" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 6, "text": "TL;DR xxd ./bin/app | vim — and :%!xxd -r > ./bin/new_app", "markups": [{"type": 10,"start": 6,"end": 27},{"type": 10,"start": 32,"end": 57}]}})
      subject.to_md[0].should eq("> TL;DR `xxd ./bin/app | vim —` and `:%!xxd -r > ./bin/new_app`")
    end

    it "renders bold link" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 6, "text": "My xxd in the world.", "markups": [{"type": 3, "start": 3,"end": 6, "href": "http://example.com"},{"type": 1,"start": 3,"end": 6}]}})
      subject.to_md[0].should eq("> My [**xxd**](http://example.com) in the world.")
    end

    it "skip render background image" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 15, "text": "picture by me", "markups": [{"type": 3, "start": 11,"end": 15, "href": "http://example.com", "title": "", "rel": "", "anchorType": 0}]}})
      subject.to_md[0].should eq("")
    end
  end
end
