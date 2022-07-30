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

    it "platform medium" do
      actual = run_with ["-v4", "--platform", "medium", "--version"]
      actual[0].should eq("#{Medup::VERSION}\n")
    end

    it "platform devto" do
      actual = run_with ["-v4", "--platform", "devto", "--version"]
      actual[0].should eq("#{Medup::VERSION}\n")
    end

    it "handles unknown platform" do
      actual = run_with ["-v4", "--platform", "foo"]
      actual[1].should contain("error: unknown platform option: foo")
    end

    it "handles unknown options" do
      actual = run_with ["--oops"], expect_success: false
      actual[0].should eq ""
      actual[1].should contain("error: unknown flag: --oops")
    end

    it "handles missing options" do
      actual = run_with ["--user"], expect_success: false
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

    it "specifies assets folder" do
      FileUtils.rm_rf "posts"
      FileUtils.rm_rf "tmp/assets"

      actual = run_with ["--assets-dir", "./tmp/assets", "-v4", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create directory ./posts})
      actual[1].should contain(%{Create directory ./tmp/assets})

      FileUtils.rm_rf "posts"
      FileUtils.rm_rf "tmp/assets"
    end

    it "specifies assets path in the result markdown" do
      FileUtils.rm_rf "posts"

      actual = run_with ["--assets-images", "--assets-base-path", "/custom_assets", "-v4", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create asset ./posts/assets/0*LZaURw4xtfA74nu9.jpeg})

      content = File.read("posts/2020-09-16-medup-backups-articles.md")
      content.should contain(%{/custom_assets/0*LZaURw4xtfA74nu9.jpeg})

      FileUtils.rm_rf "posts"
    end

    it "parse complex content with overlapped styles" do
      FileUtils.rm_rf "posts"

      actual = run_with ["--assets-images", "--assets-base-path", "/custom_assets", "-v4", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create asset ./posts/assets/0*LZaURw4xtfA74nu9.jpeg})

      content = File.read("posts/2020-09-16-medup-backups-articles.md")
      content.should contain <<-CONTENT
      ***Paul Keen** is a Chief Technology Officer at [JetThoughts](https://www.jetthoughts.com). Follow him on* [LinkedIn](https://www.linkedin.com/in/paul-keen/) *or [GitHub](https://github.com/pftg).*
      CONTENT

      FileUtils.rm_rf "posts"
    end

    it "test wrong github api token to access gist" do
      FileUtils.rm_rf "posts"

      actual = run_with ["-v12", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"], {"MEDUP_GITHUB_API_TOKEN" => "githubapitoken"}
      actual[1].should contain(%{GET https://api.github.com/gists/d7e8a19eb66734fb69cf8ee4c32095bc => 401 Unauthorized})
      actual[1].should contain(%{"Authorization" => "token githubapitoken"})
      actual[0].should contain(%{Warning: Error fetch gist from GitHub})
    end

    it "has option --dry-run=" do
      output = run_with ["--help"]
      output[0].should contain %{--dry-run}
    end

    it "does not create posts folder with dry-run" do
      FileUtils.rm_rf "posts"

      actual = run_with ["--dry-run", "-v7", "--assets-images", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
      actual[1].should contain(%{Create directory ./posts})
      actual[1].should contain(%{Create directory ./posts/assets})
      actual[1].should contain(%{Posts count: 1})
      actual[1].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.md})
      actual[1].should contain(%{Create asset ./posts/assets/0*LZaURw4xtfA74nu9.jpeg})
      File.exists?("posts").should be_false
    end

    describe "verbosity" do
      it "handles unknown options" do
        actual = run_with ["-v6", "--oops"], expect_success: false
        actual[0].should eq ""
        actual[1].should contain("error: unknown flag: --oops")
        actual[1].should contain("See 'medup --help' for usage.")
      end
    end

    describe "format" do
      it "supports format md" do
        actual = run_with ["-v4", "--format=md"], expect_success: false
        actual[1].should_not contain "error: unknown format option:"
      end

      it "supports format json" do
        actual = run_with ["-v4", "--format=json"], expect_success: false
        actual[1].should_not contain "error: unknown format option:"
      end

      it "prints error message for unknown format" do
        actual = run_with ["-v4", "--format=unknown"]
        actual[1].should contain("error: unknown format option: unknown")
      end
    end
  end

  describe "for medium platform" do
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

      it "saves article in json format" do
        output = run_with ["-v6", "--format=json", "https://medium.com/notes-and-tips-in-full-stack-development/medup-backups-articles-8bf90179b094"]
        output[1].should contain(%{Create file ./posts/2020-09-16-medup-backups-articles.json})

        files = Dir.new("posts").entries
        files.should contain("2020-09-16-medup-backups-articles.json")
        File.size("posts/2020-09-16-medup-backups-articles.json").should_not eq(0)

        content = File.read("posts/2020-09-16-medup-backups-articles.json")
        content.should contain %{"subtitle": "I am glad to present you my little project Medup to export Medium posts in markdown format."}
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
        actual = run_with ["-v4", "--publication", "version"], expect_success: false
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

  describe "for devto platform" do
    before_each do
      FileUtils.rm_rf "posts"
    end

    after_each do
      FileUtils.rm_rf "posts"
    end

    describe "single post" do
      it "downloads" do
        actual = run_with ["-v4", "https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c"]
        actual[1].should contain(%{Posts count: 1})
        actual[1].should contain(%{Create file ./posts/2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.md})
        actual[1].should contain(%{GET https://dev.to/api/articles/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c => 200 OK})

        actual[1].should contain %{GET https://res.cloudinary.com/practicaldev/image/}
      end

      it "downloads with platform" do
        actual = run_with ["-v4", "--platform=devto", "https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c"]
        actual[1].should contain(%{Posts count: 1})
        actual[1].should contain(%{Create file ./posts/2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.md})
        actual[1].should contain(%{GET https://dev.to/api/articles/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c => 200 OK})

        actual[1].should contain %{GET https://res.cloudinary.com/practicaldev/image/}
      end

      it "saves json content" do
        output = run_with ["-v4", "--format=json", "https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c"]
        output[1].should contain(%{Create file ./posts/2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.json})

        files = Dir.new("posts").entries
        files.should contain("2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.json")
        File.size("posts/2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.json").should_not eq(0)

        content = File.read("posts/2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.json")
        content.should contain %{"title": "The Trial Period for Staff Augmentation in JetThoughts"}
      end

      it "creates post file in posts folder" do
        run_with ["-v4", "https://dev.to/jetthoughts/the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c"]
        actual = Dir.new("posts").entries
        actual.should contain("2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.md")
        File.size("posts/2020-09-22-the-trial-period-for-staff-augmentation-in-jetthoughts-1h5c.md").should_not eq(0)
      end
    end

    describe "organization" do
      it "detects organization by name" do
        actual = run_with ["-v4", "https://dev.to/jetthoughts/", "--dry-run"]
        actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
        actual[1].should contain(%{Posts count: })
      end

      it "with organization name" do
        actual = run_with ["-v4", "--platform=devto", "jetthoughts", "--dry-run"]
        actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
        actual[1].should contain(%{Posts count: })
      end

      it "with organization attribute" do
        actual = run_with ["-v4", "--platform=devto", "--publication=jetthoughts", "--dry-run"]
        actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
        actual[1].should contain(%{Posts count: })
      end
    end

    describe "with user argument" do
      it "detects user by url" do
        actual = run_with ["-v4", "https://dev.to/jetthoughts/", "--dry-run"]
        actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
        actual[1].should contain(%{Posts count: })
      end

      it "detects with user name" do
        actual = run_with ["-v4", "--platform=devto", "@jetthoughts", "--dry-run"]
        actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
        actual[1].should contain(%{Posts count: })
      end

      it "detects with user attribute" do
        actual = run_with ["-v4", "--platform=devto", "--user=jetthoughts", "--dry-run"]
        actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
        actual[1].should contain(%{Posts count: })
      end

      it "missing articles" do
        actual = run_with ["-v4", "--platform=devto", "--user=unknown"], expect_success: false
        actual[1].should contain %{error: No articles to backup\nSee 'medup --help' for usage.\n}
      end
    end

    describe "with assets images argument" do
      it "creates image file" do
        actual = run_with [
          "-v4",
          "--assets-images",
          "https://dev.to/jetthoughts/how-to-use-a-transaction-script-aka-service-objects-in-ruby-on-rails-simple-example-3ll8",
          "--dry-run",
        ]
        actual[1].should contain(%{Create directory ./posts/assets})
        actual[1].should contain(%{Posts count: 1})
        actual[1].should contain %{GET https://dev-to-uploads.s3.amazonaws.com/i/z8doa4yviijb8cje161m.png => 200 OK}
        actual[1].should contain(%{Create asset ./posts/assets/z8doa4yviijb8cje161m.png})
      end
    end
  end

  describe "for mix platforms" do
    it "uses medium and devto in same command" do
      actual = run_with ["-v4", "--platform=medium", "@miry", "https://dev.to/jetthoughts/", "--dry-run"]
      actual[1].should contain(%{GET https://dev.to/api/articles?username=jetthoughts&page=1&per_page=1000 => 200 OK})
      actual[1].should contain(%{Posts count: })
      actual[1].should contain(%{GET /_/api/users/fdf238948af6/profile/stream?format=json&limit=100&source=overview => 200 OK})
    end
  end
end

def run_with(args, env : Process::Env = nil, expect_success : Bool = true)
  medup = "_output/medup"
  process = Process.new(medup, args, env, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
  stdout = process.output.gets_to_end
  stderr = process.error.gets_to_end
  process.wait.success?.should eq(expect_success)
  {stdout, stderr}
end
