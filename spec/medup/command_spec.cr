require "../spec_helper"

describe Medup::Command do
  describe ".extract_targets" do
    it "detect user with @" do
      actual = Medup::Command.extract_targets(["@miry"])
      actual[:users].should eq [{user: "miry", platform: ""}]
    end

    it "detect publication with jetthoughts" do
      actual = Medup::Command.extract_targets(["jetthoughts"])
      actual[:publications].should eq [{publication: "jetthoughts", platform: ""}]
    end

    it "detect posts with jetthoughts" do
      actual = Medup::Command.extract_targets(["https://example.com/oops", "http://example.com/oops"])
      actual[:articles].should eq(["https://example.com/oops", "http://example.com/oops"])
    end

    it "mix targets" do
      args = ["https://example.com/oops", "jetthoughts", "@miry", "foo"]
      actual = Medup::Command.extract_targets(args)
      actual[:users].should eq [{user: "miry", platform: ""}]
      actual[:publications].should eq [{publication: "jetthoughts", platform: ""}, {publication: "foo", platform: ""}]
      actual[:articles].should eq(["https://example.com/oops"])
    end

    it "detect devto user by url" do
      args = ["https://dev.to/jetthoughts/", "jetthoughts"]
      actual = Medup::Command.extract_targets(args)
      actual[:users].should eq([{user: "jetthoughts", platform: "devto"}])
      actual[:publications].should eq [{publication: "jetthoughts", platform: ""}]
    end

    it "skip article devto url" do
      args = ["https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c"]
      actual = Medup::Command.extract_targets(args)
      actual[:articles].should eq(["https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c"])
    end
  end
end
