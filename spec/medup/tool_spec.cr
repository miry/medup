require "../spec_helper"

describe Medup::Tool do
  describe "initialization" do
    it { ::Medup::Tool.new }
  end

  describe "#backup" do
    it "detects missing articles" do
      subject = ::Medup::Tool.new
      expect_raises(Exception, "No articles to backup") do
        subject.backup
      end
    end
  end
end
