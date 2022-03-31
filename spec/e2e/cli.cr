require "spec"
require "../../src/medup"

describe "CommandLine", tags: "e2e" do
  it "prints version" do
    actual = run_with ["--version"]
    actual[0].should eq("#{Medup::VERSION}\n")
  end

  it "prints help" do
    actual = run_with ["--help"]
    actual[0].should contain("Usage:\n  medup [arguments] [article url]\n\n")
  end

  it "handles unknown options" do
    actual = run_with ["--oops"], false
    actual[0].should eq ""
    actual[1].should contain("error: unknown flag: --oops")
  end

  it "handles missing options" do
    actual = run_with ["--user"], false
    actual[0].should eq ""
    actual[1].should contain("error: flag needs an argument: --user")
  end

  it "detects single not valid url" do
    actual = run_with ["http://example.com"]
    actual[0].should contain(%{GET http://example.com?format=json => 200 OK})
    actual[1].should contain(%{error: could not process http://example.com: unsupported content type text/html})
  end

  it "download medium from custom domain" do
    actual = run_with ["https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
    actual[0].should contain(%{200 OK})
    actual[1].should eq("")
  end

  it "download medium from custom domain" do
    actual = run_with ["https://jtway.co/git-minimum-for-effective-project-development-841a0b865ef0"]
    actual[0].should contain(%{307 Temporary Redirect})
    actual[0].should contain(%{200 OK})
  end
end

def run_with(args, expect_success : Bool = true)
  medup = "_output/medup"
  process = Process.new(medup, args, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
  stdout = process.output.gets_to_end
  stderr = process.error.gets_to_end
  process.wait.success?.should eq(expect_success)
  {stdout, stderr}
end
