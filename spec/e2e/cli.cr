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

      actual = run_with ["-v4", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create directory ./posts})
      actual[1].should contain(%{Create directory ./posts/assets})

      actual = Dir.new("posts").entries
      actual.should contain("assets")
    end

    it "specifies another folder" do
      FileUtils.rm_rf "tmp/posts"

      actual = run_with ["-v4", "-d", "tmp/posts", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create directory tmp/posts})
      actual[1].should contain(%{Create directory tmp/posts/assets})

      actual = Dir.new("tmp/posts").entries
      actual.should contain("assets")

      FileUtils.rm_rf "tmp/posts"
    end

    describe "verbosity" do
      it "handles unknown options" do
        actual = run_with ["-v6", "--oops"], false
        actual[0].should eq ""
        actual[1].should contain("error: unknown flag: --oops")
        actual[1].should contain("See 'medup --help' for usage.")
      end
    end
  end

  describe "single post" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    it "detects single not valid url" do
      actual = run_with ["-v4", "http://example.com"]
      actual[1].should contain(%{error: could not process http://example.com: unsupported content type text/html})
    end

    it "downloads iframe from medium, youtube in assets and gist embeded" do
      actual = run_with ["-v4", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Posts count: 1})
      actual[1].should contain(%{GET https://medium.com/@/8bf90179b094?format=json => 200 OK})
      # Download Gist media element
      actual[1].should contain(%{GET https://api.github.com/gists/d7e8a19eb66734fb69cf8ee4c32095bc => 200 OK})
      actual[1].should_not contain(%{403 rate limit exceeded})
      # Download Youtube media element
      actual[1].should contain(%{GET https://medium.com/media/8fd52e6662e183023fe4dce238d9729b => 200 O})
      actual[1].should contain(%{GET https://miro.medium.com/1*CSF4xue7yFfg-9-wxAkDWw.jpeg => 200 OK})

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2020-09-16-medup-backups-articles.md")

      actual = Dir.new("posts/assets").entries
      actual.sort.should_not contain("d7e8a19eb66734fb69cf8ee4c32095bc.html") # gist content
      actual.sort.should_not contain("8fd52e6662e183023fe4dce238d9729b.html") # youtube content
    end

    it "download medium from custom domain" do
      actual = run_with ["-v6", "https://jtway.co/git-minimum-for-effective-project-development-841a0b865ef0"]
      actual[1].should contain(%{307 Temporary Redirect})
      actual[1].should contain(%{200 OK})

      actual = Dir.new("posts").entries
      actual.size.should eq(4)
      actual.should contain("assets")
      actual.should contain("2020-04-14-git-minimum-for-effective-project-development.md")
    end

    it "saves images in assets folder" do
      actual = run_with ["-v6", "--assets-images", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Posts count: 1})
      actual[1].should contain(%{GET https://miro.medium.com/1*CSF4xue7yFfg-9-wxAkDWw.jpeg => 200 OK})
      actual[1].should contain(%{GET https://miro.medium.com/0*LZaURw4xtfA74nu9 => 200 OK})
      actual[1].should contain(%{Create asset ./posts/assets/0*LZaURw4xtfA74nu9.jpeg})

      actual = Dir.new("posts/assets").entries
      actual.should contain("1*CSF4xue7yFfg-9-wxAkDWw.jpeg")
      actual.should contain("0*LZaURw4xtfA74nu9.jpeg")
    end

    it "skip existing aritcles" do
      actual = run_with ["-v6", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})

      old_info = File.new("posts/2020-09-16-medup-backups-articles.md").info

      actual = run_with ["-v6", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should_not contain(%{Create file})

      new_info = File.new("posts/2020-09-16-medup-backups-articles.md").info
      new_info.modification_time.should eq(old_info.modification_time)
    end

    it "update content for existing aritcles if option provided" do
      actual = run_with ["-v6", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})

      old_info = File.new("posts/2020-09-16-medup-backups-articles.md").info

      actual = run_with ["-v6", "--update", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})

      new_info = File.new("posts/2020-09-16-medup-backups-articles.md").info
      new_info.modification_time.should_not eq(old_info.modification_time)
    end

    it "checks articles with rich elements codepen" do
      actual = run_with ["-v6", "https://jtway.co/rscss-styling-css-without-losing-your-sanity-9e622d9f9252"]
      actual[1].should contain(%{Create file ./posts/2019-06-07-rscss-styling-css-without-losing-your-sanity.md})
      actual = Dir.new("posts/assets").entries
      actual.sort.should eq([".", ".."])
    end
  end

  describe "publication" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    it "download posts for publication" do
      actual = run_with ["-v4", "--publication", "notes-and-tips-in-full-stack-development"]
      actual[1].should contain(%{GET /notes-and-tips-in-full-stack-development/archive?format=json => 200 OK})
      actual[1].should contain(%{GET https://medium.com/@/c35b40c499e?format=json => 200 OK})

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2017-03-20-war-with-ads-and-trackers.md")
      actual.should contain("2020-09-16-medup-backups-articles.md")
    end

    it "unknown publication" do
      actual = run_with ["-v4", "--publication", "version"], false
      actual[1].should contain(%{GET /version/archive?format=json => 404 Not Found})
      actual[1].should contain("error: ")
    end
  end

  describe "user" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    it "download posts from user" do
      actual = run_with ["-v4", "--user", "kristinazakharchenko"]
      actual[1].should contain(%{GET /@kristinazakharchenko?format=json => 200 OK})
      actual[1].should contain(%{GET /_/api/users/a002e103d8f7/profile/stream?format=json&limit=100&source=overview => 200 OK})

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2022-03-25-i-was-born-into-a-military-family-now-im-making-bulletproof-vests-for-ukraine.md")
    end

    it "download posts from user without option" do
      actual = run_with ["-v4", "@kristinazakharchenko"]
      actual[1].should contain(%{GET /@kristinazakharchenko?format=json => 200 OK})
      actual[1].should contain(%{GET /_/api/users/a002e103d8f7/profile/stream?format=json&limit=100&source=overview => 200 OK})

      actual = Dir.new("posts").entries
      actual.should contain("assets")
      actual.should contain("2022-03-25-i-was-born-into-a-military-family-now-im-making-bulletproof-vests-for-ukraine.md")
    end

    it "download posts from user recommendations" do
      actual = run_with ["-v4", "--user", "doctorow", "--recommended"]
      actual[1].should contain(%{GET /@doctorow?format=json => 200 OK})
      actual[1].should contain(%{GET /_/api/users/eba9888d741b/profile/stream?format=json&limit=100&source=has-recommended => 200 OK})
      actual[1].should contain(%{Create file ./posts/2014-09-02-the-gadget-and-the-burn.md})

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
