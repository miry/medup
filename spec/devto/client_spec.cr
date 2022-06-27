require "../spec_helper"

describe Devto::Client do
  describe "#convert_to_api_url" do
    it "converts basic url" do
      subject = ::Devto::Client.new(::Medup::Context.new)
      actual = subject.convert_to_api_url("https://dev.to/jetthoughts/how-to-use-linear-gradient-in-css-bi1")
      expected = "https://dev.to/api/articles/jetthoughts/how-to-use-linear-gradient-in-css-bi1"
      actual.should eq(expected)
    end
  end
end
