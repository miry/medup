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
      subject.content.bodyModel.paragraphs.size.should eq(15)
    end
  end

  describe "#to_md" do
    it "render full page" do
      subject = Medium::Post.from_json(post_fixture)
      subject.to_md.size.should eq(1489)
    end

    it "renders header" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[0]
      paragraph.to_md.should eq("# Modify binary files with VIM")
    end

    it "renders blockquotes" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[1]
      paragraph.to_md.should eq("> TL;DR xxd ./bin/app | vim — and :%!xxd -r > ./bin/new_app")
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
        paragraph.to_md.should contain("**W**hen I was a student")
      end

      it "renders content with links" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[3]
        paragraph.to_md.should contain("like [Total Commander](https://www.ghisler.com/) or [FAR manager](https://www.farmanager.com/)")
      end

      it "renders content with bold text with link" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[7]
        paragraph.to_md.should contain("I came to: [**xxd**](http://vim.fandom.com/wiki/Hex_dump)")
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

    it "render split" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md.should eq("---")
    end

    it "render iframe" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md.should eq("???")
    end

    it "render code block" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md.should eq("???")
    end
  end
end
