require "../spec_helper"

describe Medium::User do
  describe "initialize" do
    it "load from fixtures" do
      subject = Medium::User.from_json(user_fixture)
      subject.userId.should eq("fdf238948af6")
      subject.name.should eq("Michael Nikitochkin")
      subject.username.should eq("miry")
    end
  end
end
