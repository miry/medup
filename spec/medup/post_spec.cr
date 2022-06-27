require "../spec_helper"

describe Medup::Post do
  it "initialize" do
    ::Medup::Post.new
  end

  describe ".to_pretty_json" do
    it "prints empty if no json setup" do
      subject = ::Medup::Post.new
      subject.to_pretty_json.should eq("")
    end

    it "prints pretty if raw is set" do
      subject = ::Medup::Post.new
      subject.raw = %|{"id":1,"slug":"oops"}|
      subject.to_pretty_json.should eq <<-JSON
      {
        "id": 1,
        "slug": "oops"
      }
      JSON
    end
  end

  it ".to_md" do
    subject = ::Medup::Post.new
    content, assets = subject.to_md
    content.should eq("")
    assets.size.should eq(0)
  end

  it ".slug" do
    subject = ::Medup::Post.new
    subject.slug.should eq("")
  end

  it ".created_at" do
    subject = ::Medup::Post.new
    subject.created_at.should be_a(Time)
  end
end
