require "../spec_helper"

describe Medup::Command do
  describe ".extract_targets" do
    it "detect user with @" do
      actual = Medup::Command.extract_targets(["@miry"])
      actual[:users].should contain("miry")
    end

    it "detect publication with jetthoughts" do
      actual = Medup::Command.extract_targets(["jetthoughts"])
      actual[:publications].should contain("jetthoughts")
    end

    it "detect posts with jetthoughts" do
      actual = Medup::Command.extract_targets(["https://example.com/oops", "http://example.com/oops"])
      actual[:articles].should eq(["https://example.com/oops", "http://example.com/oops"])
    end

    it "mix targets" do
      args = ["https://example.com/oops", "jetthoughts", "@miry", "foo"]
      actual = Medup::Command.extract_targets(args)
      actual[:users].should eq(["miry"])
      actual[:publications].should eq(["jetthoughts", "foo"])
      actual[:articles].should eq(["https://example.com/oops"])
    end
  end
end
