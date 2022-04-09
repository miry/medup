require "spec"
require "file_utils"

require "../../src/medup"

describe "CommandLine", tags: "e2e" do
  describe "options" do
    it "prints version" do
      actual = run_with ["--version"]
      actual[0].should eq("#{Medup::VERSION}\n")
    end

    it "prints help" do
      actual = run_with ["--help"]
      actual[0].should contain("Usage:\n  medup [arguments] [@user or publication name or url]\n\n")
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

    it "creates posts folder if missing" do
      FileUtils.rm_rf "posts"

      actual = run_with ["https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Create directory ./posts\n})
      actual[0].should contain(%{Create directory ./posts/assets})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.should contain("assets")
    end

    it "specifies another folder" do
      FileUtils.rm_rf "tmp/posts"

      actual = run_with ["-d", "tmp/posts", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Create directory tmp/posts\n})
      actual[0].should contain(%{Create directory tmp/posts/assets})
      actual[1].should eq("")

      actual = Dir.new("tmp/posts").entries
      actual.should contain("assets")

      FileUtils.rm_rf "tmp/posts"
    end
  end

  describe "single post" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    it "detects single not valid url" do
      actual = run_with ["http://example.com"]
      actual[0].should contain(%{GET http://example.com?format=json => 200 OK})
      actual[1].should contain(%{error: could not process http://example.com: unsupported content type text/html})
    end

    it "download medium from medium domain" do
      actual = run_with ["https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Posts count: 1})
      actual[0].should contain(%{200 OK})
      actual[0].should contain(%{GET https://medium.com/media/d0aa4300e50ebcf6d244dd91e836bc5f => 200 OK})
      actual[0].should contain(%{Create asset ./posts/assets/d0aa4300e50ebcf6d244dd91e836bc5f.html})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2020-09-16-medup-backups-articles.md")

      actual = Dir.new("posts/assets").entries
      actual.should contain("d0aa4300e50ebcf6d244dd91e836bc5f.html")
    end

    it "download medium from custom domain" do
      actual = run_with ["https://jtway.co/git-minimum-for-effective-project-development-841a0b865ef0"]
      actual[0].should contain(%{307 Temporary Redirect})
      actual[0].should contain(%{200 OK})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.size.should eq(4)
      actual.should contain("assets")
      actual.should contain("2020-04-14-git-minimum-for-effective-project-development.md")
    end

    it "saves images in assets folder" do
      actual = run_with ["--assets-images", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Posts count: 1})
      actual[0].should contain(%{GET https://miro.medium.com/1*CSF4xue7yFfg-9-wxAkDWw.jpeg => 200 OK})
      actual[0].should contain(%{GET https://miro.medium.com/0*LZaURw4xtfA74nu9 => 200 OK})
      actual[0].should contain(%{GET https://medium.com/media/d0aa4300e50ebcf6d244dd91e836bc5f => 200 OK})
      actual[0].should contain(%{Create asset ./posts/assets/0*LZaURw4xtfA74nu9.jpeg})
      actual[0].should contain(%{Create asset ./posts/assets/d0aa4300e50ebcf6d244dd91e836bc5f.html})
      actual[1].should eq("")

      actual = Dir.new("posts/assets").entries
      actual.should contain("1*CSF4xue7yFfg-9-wxAkDWw.jpeg")
      actual.should contain("0*LZaURw4xtfA74nu9.jpeg")
      actual.should contain("d0aa4300e50ebcf6d244dd91e836bc5f.html")
    end

    it "skip existing aritcles" do
      actual = run_with ["https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})
      actual[1].should eq("")

      old_info = File.new("posts/2020-09-16-medup-backups-articles.md").info

      actual = run_with ["https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should_not contain(%{Create file})
      actual[1].should eq("")

      new_info = File.new("posts/2020-09-16-medup-backups-articles.md").info
      new_info.modification_time.should eq(old_info.modification_time)
    end

    it "update content for existing aritcles if option provided" do
      actual = run_with ["https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})
      actual[1].should eq("")

      old_info = File.new("posts/2020-09-16-medup-backups-articles.md").info

      actual = run_with ["--update", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[0].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})
      actual[1].should eq("")

      new_info = File.new("posts/2020-09-16-medup-backups-articles.md").info
      new_info.modification_time.should_not eq(old_info.modification_time)
    end
  end

  describe "publication" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    it "download posts for publication" do
      actual = run_with ["--publication", "notes-and-tips-in-full-stack-development"]
      actual[0].should contain(%{GET /notes-and-tips-in-full-stack-development/archive?format=json => 200 OK})
      actual[0].should contain(%{GET https://medium.com/@/c35b40c499e?format=json => 200 OK})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2017-03-20-war-with-ads-and-trackers.md")
      actual.should contain("2020-09-16-medup-backups-articles.md")
    end
  end

  describe "user" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    it "download posts from user" do
      actual = run_with ["--user", "kristinazakharchenko"]
      actual[0].should contain(%{GET /@kristinazakharchenko?format=json => 200 OK})
      actual[0].should contain(%{GET /_/api/users/a002e103d8f7/profile/stream?format=json&limit=100&source=overview => 200 OK})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2022-03-25-i-was-born-into-a-military-family-now-im-making-bulletproof-vests-for-ukraine.md")
    end

    it "download posts from user without option" do
      actual = run_with ["@kristinazakharchenko"]
      actual[0].should contain(%{GET /@kristinazakharchenko?format=json => 200 OK})
      actual[0].should contain(%{GET /_/api/users/a002e103d8f7/profile/stream?format=json&limit=100&source=overview => 200 OK})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2022-03-25-i-was-born-into-a-military-family-now-im-making-bulletproof-vests-for-ukraine.md")
    end

    it "download posts from user recommendations" do
      actual = run_with ["--user", "doctorow", "--recommended"]
      actual[0].should contain(%{GET /@doctorow?format=json => 200 OK})
      actual[0].should contain(%{GET /_/api/users/eba9888d741b/profile/stream?format=json&limit=100&source=has-recommended => 200 OK})
      actual[0].should contain(%{Create file ./posts/2014-09-02-the-gadget-and-the-burn.md})
      actual[1].should eq("")

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2015-01-05-a-mile-wide-an-inch-deep.md")

      article = File.read("posts/2015-01-05-a-mile-wide-an-inch-deep.md")
      article.should contain(%{author: Ev Williams}) # Different author from doctorow
    end
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
