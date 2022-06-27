require "../spec_helper"

describe Devto::Post do
  describe ".from_json" do
    it "loads sample post" do
      subject = Devto::Post.from_json(%|{"id": 1}|)
      subject.slug.should eq("")
      subject.id.should eq(1)
    end

    it "sets slug" do
      subject = Devto::Post.from_json(%|{"id": 1, "slug": "how-to-use-linear-gradient-in-css-bi1"}|)
      subject.slug.should eq("how-to-use-linear-gradient-in-css-bi1")
    end

    it "tests the fixture" do
      content = File.read(File.join("spec", "fixtures", "devto_article_trial_period.json"))
      subject = Devto::Post.from_json content
      subject.slug.should eq("the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c")
    end
  end

  describe "#to_md" do
    before_each do
      WebMock.stub(:get, "https://res.cloudinary.com/practicaldev/image/fetch/s--Fkj0zHXm--/c_imagga_scale,f_auto,fl_progressive,h_420,q_auto,w_1000/https://dev-to-uploads.s3.amazonaws.com/i/0vqbsdg8l5onq2cpvjho.png")
        .to_return(
          body: %{image content},
          headers: HTTP::Headers{"Content-Type" => "image/jpeg"})
    end

    it "renders a sample page" do
      content = File.read(File.join("spec", "fixtures", "devto_article_trial_period.json"))
      subject = Devto::Post.from_json content
      content, assets = subject.to_md
      content.size.should eq 2578
      assets.size.should eq 1
    end

    it "renders the header section" do
      content = File.read(File.join("spec", "fixtures", "devto_article_trial_period.json"))
      subject = Devto::Post.from_json content
      content, assets = subject.to_md
      content.should contain <<-HEADER
      ---
      url: https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c
      canonical_url: https://jtway.co/the-trial-period-in-jetthoughts-968e7f01481f?source=friends_link&sk=56dbdb8567ab7500796037d42c80e46a
      title: The Trial Period for Staff Augmentation in JetThoughts
      slug: the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c
      description: We offer a 2-week trial with no obligation. So you can test everything and see how it goes with no fi...
      tags: startup, engagement, team, development
      ---
      HEADER
    end

    it "renders the cover image" do
      content = File.read(File.join("spec", "fixtures", "devto_article_trial_period.json"))
      subject = Devto::Post.from_json content
      content, assets = subject.to_md
      content.should contain <<-IMAGE
      ![Cover image][img_ref_cover_image]
      IMAGE

      content.should contain <<-IMAGE
      [img_ref_cover_image]: data:image/jpeg;base64,aW1hZ2UgY29udGVudA==
      IMAGE

      assets.has_key?("img_ref_cover_image").should be_true
    end
  end

  describe "#md_content" do
    it "parses image tags" do
      WebMock.stub(:get, "https://example.com/image_url1.png")
        .to_return(
          body: %{image content},
          headers: HTTP::Headers{"Content-Type" => "image/jpeg"})
      WebMock.stub(:get, "https://example.com/image_url2.png")
        .to_return(
          body: %{image content},
          headers: HTTP::Headers{"Content-Type" => "image/jpeg"})
      WebMock.stub(:get, "https://example.com/image_url3.png")
        .to_return(
          body: %{image content},
          headers: HTTP::Headers{"Content-Type" => "image/jpeg"})

      subject = Devto::Post.from_json <<-'CONTENT'
      {
        "body_markdown": "# Title\n![Image](https://example.com/image_url1.png) ![Image](https://example.com/image_url2.png) ![Image](https://example.com/image_url3.png)"
      }
      CONTENT
      assets = Hash(String, String).new
      actual = subject.md_content(assets)
      actual.should eq "# Title\n![Image][img_ref_image_url1_png] ![Image][img_ref_image_url2_png] ![Image][img_ref_image_url3_png]"
      assets.size.should eq 3
      assets.keys.sort.join(" ").should eq "img_ref_image_url1_png img_ref_image_url2_png img_ref_image_url3_png"
    end
  end
end
