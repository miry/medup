require "../spec_helper"

describe Medium::Post do
  describe "initialize" do
    it "initialize from json" do
      subject = Medium::Post.from_json(post_fixture)
      subject.should_not eq(nil)
    end

    it "setups title" do
      subject = Medium::Post.from_json(post_fixture)
      subject.title.should eq("Modify binary files with VIM")
    end

    it "setups slug" do
      subject = Medium::Post.from_json(post_fixture)
      subject.slug.should eq("modify-binary-files-with-vim")
    end

    it "setups content" do
      subject = Medium::Post.from_json(post_fixture)
      subject.content.bodyModel.paragraphs.size.should eq(21)
    end
  end

  describe "#url" do
    it "set url" do
      subject = Medium::Post.from_json(post_fixture)
      subject.url = "example.com"
      subject.url.should eq("example.com")
    end
  end

  describe "#to_md" do
    it "render full page" do
      subject = Medium::Post.from_json(post_fixture)
      subject.to_md.size.should eq(2801)
    end

    it "renders header" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[0]
      paragraph.to_md.should eq("# Modify binary files with VIM")
    end

    it "renders blockquotes" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[1]
      paragraph.to_md.should eq("> TL;DR `xxd ./bin/app | vim —` and `:%!xxd -r > ./bin/new_app`")
    end

    it "renders image" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[2]
      paragraph.to_md.should eq("![Photo by Markus Spiske on Unsplash](./assets/0*FbFs8aNmqNLKw4BM)")
    end

    describe "paragraph text" do
      it "renders content with capital letter" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[3]
        paragraph.to_md.should contain("When I was a student")
      end

      it "renders content with links" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[3]
        paragraph.to_md.should contain("like [Total Commander](https://www.ghisler.com/) or [FAR manager](https://www.farmanager.com/)")
      end

      it "renders content with bold text with link" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[7]
        paragraph.to_md.should contain("I came to: [**xxd**](http://vim.wikia.com/wiki/Hex_dump)")
      end

      it "renders content with inline code block" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[7]
        paragraph.to_md.should contain(%{of `vim-common` package})
      end
    end

    it "renders numered list first" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[5]
      paragraph.to_md.should eq("1. it should be cross distributive solution")
    end

    it "renders numered list second" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[6]
      paragraph.to_md.should eq("1. should be easy to use with Vim (as main my editor for linux machines)")
    end

    pending "render split" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md.should eq("---")
    end

    it "render iframe" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md.should eq("<iframe src=\"./assets/ab24f0b378f797307fddc32f10a99685.html\"></iframe>")
    end

    it "render code block" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[15]
      paragraph.to_md.should contain(%{```\n[terminal 1]})
    end

    describe "metadata" do
      it "stores description information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        subject.to_md.should contain(%{description: Sometime I need to open binaries})
      end

      it "stores subtitle information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        subject.to_md.should contain(%{subtitle: Edit binary files in Linux with Vim})
      end

      it "stores tags information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        subject.to_md.should contain(%{tags: vim,debug,linux,cracking,hacking})
      end
    end
  end
end
