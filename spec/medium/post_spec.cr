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
      subject.content.bodyModel.paragraphs.size.should eq(22)
    end

    it "missing name" do
      subject = Medium::Post.from_json(post_without_name_fixture)
      subject.content.bodyModel.paragraphs.size.should eq(58)
    end

    it "missing drop cap image" do
      subject = Medium::Post.from_json(post_without_dropimage_fixture)
      subject.content.bodyModel.paragraphs.size.should eq(39)
    end
  end

  describe "#to_md" do
    it "render full page" do
      subject = Medium::Post.from_json(post_fixture)
      content, assets = subject.to_md
      content.size.should eq(3206)
      assets.size.should eq(1)
      assets.keys.should eq([
        "ab24f0b378f797307fddc32f10a99685.html",
      ])
    end

    it "render full page without images" do
      subject = Medium::Post.from_json(post_fixture)
      settings = ::Medup::Settings.new
      settings.set_assets_image!
      subject.ctx = ::Medup::Context.new(settings)

      content, assets = subject.to_md
      content.size.should eq(2932)
      assets.keys.should eq([
        "0*FbFs8aNmqNLKw4BM.png",
        "ab24f0b378f797307fddc32f10a99685.html",
        "1*NVLl4oVmMQtumKL-DVV1rA.png",
      ])
    end

    it "renders header" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[0]
      paragraph.to_md[0].should eq("# Modify binary files with VIM")
    end

    it "renders blockquotes" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[1]
      paragraph.to_md[0].should eq("> TL;DR `xxd ./bin/app | vim —` and `:%!xxd -r > ./bin/new_app`")
    end

    it "renders image" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[2]
      actual = paragraph.to_md
      actual[0].should eq("![Photo by Markus Spiske on Unsplash][image_ref_MCpGYkZzOGFObXFOTEt3NEJN]")
      actual[1].should eq("0*FbFs8aNmqNLKw4BM.png")
      actual[2][0..64].should eq("[image_ref_MCpGYkZzOGFObXFOTEt3NEJN]: data:image/png;base64,iVBOR")
    end

    it "renders image in assets" do
      subject = Medium::Post.from_json(post_fixture)
      settings = ::Medup::Settings.new
      settings.set_assets_image!
      ctx = ::Medup::Context.new(settings)

      paragraph = subject.content.bodyModel.paragraphs[2]
      actual = paragraph.to_md(ctx)
      actual[0].should eq("![Photo by Markus Spiske on Unsplash](./assets/0*FbFs8aNmqNLKw4BM.png)")
      actual[1].should eq("0*FbFs8aNmqNLKw4BM.png")
      actual[2].size.should eq(66)
    end

    describe "paragraph text" do
      it "renders content with capital letter" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[3]
        paragraph.to_md[0].should contain("When I was a student")
      end

      it "renders content with links" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[3]
        paragraph.to_md[0].should contain("like [Total Commander](https://www.ghisler.com/) or [FAR manager](https://www.farmanager.com/)")
      end

      it "renders content with bold text with link" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[7]
        paragraph.to_md[0].should contain("I came to: [**xxd**](http://vim.wikia.com/wiki/Hex_dump)")
      end

      it "renders content with inline code block" do
        subject = Medium::Post.from_json(post_fixture)
        paragraph = subject.content.bodyModel.paragraphs[7]
        paragraph.to_md[0].should contain(%{of `vim-common` package})
      end
    end

    it "renders numered list first" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[5]
      paragraph.to_md[0].should eq("1. it should be cross distributive solution")
    end

    it "renders numered list second" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[6]
      paragraph.to_md[0].should eq("1. should be easy to use with Vim (as main my editor for linux machines)")
    end

    pending "render split" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md[0].should eq("---")
    end

    it "render iframe" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[12]
      paragraph.to_md[0].should eq("<iframe src=\"./assets/ab24f0b378f797307fddc32f10a99685.html\"></iframe>")
    end

    it "render code block" do
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[15]
      paragraph.to_md[0].should contain(%{```\n[terminal 1]})
    end

    it "understands alignment attribute" do
      # Original: https://medium.com/@jico/the-fine-art-of-javascript-error-tracking-bc031f24c659
      subject = Medium::Post.from_json(post_fixture)
      paragraph = subject.content.bodyModel.paragraphs[21]
      paragraph.to_md[0].should contain(%{# The Title with image})
    end

    describe "metadata" do
      it "stores description information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        subject.to_md[0].should contain(%{description: Sometime I need to open binaries})
      end

      it "stores subtitle information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        subject.to_md[0].should contain(%{subtitle: Edit binary files in Linux with Vim})
      end

      it "stores tags information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        subject.to_md[0].should contain(%{tags: vim,debug,linux,cracking,hacking})
      end

      it "stores author name information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        user = Medium::User.from_json(user_fixture)
        subject.user = user
        subject.to_md[0].should contain(%{author: Michael Nikitochkin})
      end

      it "stores username information in metadata" do
        subject = Medium::Post.from_json(post_fixture)
        user = Medium::User.from_json(user_fixture)
        subject.user = user
        subject.to_md[0].should contain(%{username: miry})
      end
    end
  end
end
