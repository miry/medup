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
      subject.to_md.should eq("# Modify binary files with VIM")
    end

    it "renders blockquotes" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 6, "text": "TLDR text", "markups": []}})
      subject.to_md.should eq("> TLDR text")
    end

    it "renders blockquotes second style" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 7, "text": "TLDR text", "markups": []}})
      subject.to_md.should eq(">> TLDR text")
    end

    it "renders images" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 4, "text": "Photo", "layout": 3, "metadata":{"id":"0*FbFs8aNmqNLKw4BM"}, "markups": []}})
      subject.to_md.should eq("![Photo](./assets/0*FbFs8aNmqNLKw4BM)")
    end

    it "render number list" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 10, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md.should eq("1. it should be cross distributive solution")
    end

    it "render unordered list" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 9, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md.should eq("* it should be cross distributive solution")
    end

    it "render text" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 1, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md.should eq("it should be cross distributive solution")
    end

    it "render code block" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 8, "text": "puts hello", "markups": []}})
      subject.to_md.should eq("```\nputs hello\n```")
    end

    it "render small header" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 13, "text": "Help", "markups": []}})
      subject.to_md.should eq("### Help")
    end

    it "render link references" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 14, "text": "Socket::Addrinfo", "markups": [], "mixtapeMetadata": {"mediaResourceId": "7f3accd276b8655a927e5d50f276d49d","href":"https://crystal-lang.org/api/0.31.0/Socket/Addrinfo.html"}}})
      subject.to_md.should eq("https://crystal-lang.org/api/0.31.0/Socket/Addrinfo.html")
    end

    it "render image with link" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 4, "text": "", "layout": 3, "href": "https://asciinema.org/a/5diw0wwk6vbbovnqrk5sh1soy", "markups": [], "metadata":{"id": "1*NVLl4oVmMQtumKL-DVV1rA.png"}}})
      subject.to_md.should eq("[![](./assets/1*NVLl4oVmMQtumKL-DVV1rA.png)](https://asciinema.org/a/5diw0wwk6vbbovnqrk5sh1soy)")
    end
  end
end
