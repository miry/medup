require "../../spec_helper"

describe Medium::Post::Paragraph do
  it "initialize" do
    subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 3, "text": "Modify binary files with VIM", "markups": []}})
    subject.name.should eq("d2a9")
    subject.text.should eq("Modify binary files with VIM")
    subject.type.should eq(3)
  end

  describe "#to_md" do
    it "renders header" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 3, "text": "Modify binary files with VIM", "markups": []}})
      subject.to_md[0].should eq("# Modify binary files with VIM")
    end

    it "renders blockquotes" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 6, "text": "TLDR text", "markups": []}})
      subject.to_md[0].should eq("> TLDR text")
    end

    it "renders blockquotes second style" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 7, "text": "TLDR text", "markups": []}})
      subject.to_md[0].should eq(">> TLDR text")
    end

    it "renders images" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 4, "text": "Photo", "layout": 3, "metadata":{"id":"0*FbFs8aNmqNLKw4BM"}, "markups": []}})
      content, asset_name, assets = subject.to_md
      content.should eq("![Photo][image_ref_MCpGYkZzOGFObXFOTEt3NEJN]")
      assets.should match(/^\[image_ref_MCpGYkZzOGFObXFOTEt3NEJN\]:/)
      asset_name.should eq("0*FbFs8aNmqNLKw4BM.png")
    end

    it "renders images with assets" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "78ee", "type": 4, "text": "Photo", "layout": 3, "metadata":{"id":"0*FbFs8aNmqNLKw4BM"}, "markups": []}})
      content, asset_name, assets = subject.to_md([::Medup::Options::ASSETS_IMAGE])
      content.should eq("![Photo](./assets/0*FbFs8aNmqNLKw4BM.png)")
      assets.size.should eq(66)
      asset_name.should eq("0*FbFs8aNmqNLKw4BM.png")
    end

    it "render number list" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 10, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md[0].should eq("1. it should be cross distributive solution")
    end

    it "render unordered list" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 9, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md[0].should eq("* it should be cross distributive solution")
    end

    it "render text" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 1, "text": "it should be cross distributive solution", "markups": []}})
      subject.to_md[0].should eq("it should be cross distributive solution")
    end

    it "render title" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 2, "text": "render title with picture", "markups": [], "alignment": 2}})
      subject.to_md[0].should eq("# render title with picture")
    end

    it "render title with links" do
      entity_raw = %{
        {
          "name": "2612",
          "type": 13,
          "text": "🇺🇦 JetThoughts: REsize Amazon EBS volumes without a reboot",
          "markups": [
            {
              "type": 3,
              "start": 0,
              "end": 16,
              "href": "https://jtway.co/resize-amazon-ebs-volumes-without-a-reboot-ca118b010b44",
              "title": "",
              "rel": "",
              "anchorType": 0
            }
          ]
        }
      }

      subject = Medium::Post::Paragraph.from_json(entity_raw)
      subject.to_md[0].should eq("### [🇺🇦 JetThoughts](https://jtway.co/resize-amazon-ebs-volumes-without-a-reboot-ca118b010b44): REsize Amazon EBS volumes without a reboot")
    end

    it "render code block" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 8, "text": "puts hello", "markups": []}})
      subject.to_md[0].should eq("```\nputs hello\n```")
    end

    it "render small header" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 13, "text": "Help", "markups": []}})
      subject.to_md[0].should eq("### Help")
    end

    it "render link references" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 14, "text": "Socket::Addrinfo", "markups": [], "mixtapeMetadata": {"mediaResourceId": "7f3accd276b8655a927e5d50f276d49d","href":"https://crystal-lang.org/api/0.31.0/Socket/Addrinfo.html"}}})
      subject.to_md[0].should eq("https://crystal-lang.org/api/0.31.0/Socket/Addrinfo.html")
    end

    it "render image with link" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 4, "text": "", "layout": 3, "href": "https://asciinema.org/a/5diw0wwk6vbbovnqrk5sh1soy", "markups": [], "metadata":{"id": "1*NVLl4oVmMQtumKL-DVV1rA.png"}}})
      content, assets = subject.to_md
      content.should eq("[![][image_ref_MSpOVkxsNG9WbU1RdHVtS0wtRFZWMXJBLnBuZw==]](https://asciinema.org/a/5diw0wwk6vbbovnqrk5sh1soy)")
    end

    describe "iframe" do
      it "render iframe inline" do
        subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 11, "text": "", "markups": [], "iframe":{"mediaResourceId": "e7722acf2*886364130e03d2c7ad29de7"}}})
        subject.to_md[0].should eq(%{<iframe src="./assets/e7722acf2886364130e03d2c7ad29de7.html"></iframe>})
      end

      it "annotation text with markups" do
        WebMock.stub(:get, "https://medium.com/media/codepensample")
          .to_return(
            body: %{
                <html><title>Some title of video – Medium</title>
                <body>
                <iframe
    src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fcodepen.io%2Fandriyparashchuk%2Fembed%2Fpreview%2FWqrrWK%3Fheight%3D600%26slug-hash%3DWqrrWK%26default-tabs%3Dhtml%2Cresult%26host%3Dhttps%3A%2F%2Fcodepen.io&amp;url=https%3A%2F%2Fcodepen.io%2Fandriyparashchuk%2Fpen%2FWqrrWK%3Feditors%3D1100&amp;image=https%3A%2F%2Fscreenshot.codepen.io%2F3285523.WqrrWK.small.c25731c6-e071-4f90-bef2-998307289afa.png&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;type=text%2Fhtml&amp;schema=codepen"
    allowfullscreen frameborder="0" scrolling="no"></iframe>
                </body>
                </html>
              },
            headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

        subject = Medium::Post::Paragraph.from_json(%{
          {
            "name": "0ad9",
            "type": 11,
            "text": "https://codepen.io/andriyparashchuk/pen/WqrrWK?editors=1100",
            "markups": [
              {
                "type": 3,
                "start": 0,
                "end": 59,
                "href": "https://codepen.io/andriyparashchuk/pen/WqrrWK?editors=1100",
                "title": "",
                "rel": "",
                "anchorType": 0
              }
            ],
            "layout": 1,
            "iframe": {
              "mediaResourceId": "codepensample",
              "iframeWidth": 800,
              "iframeHeight": 600,
              "thumbnailUrl": "https://i.embed.ly/1/image?url=https%3A%2F%2Fscreenshot.codepen.io%2F3285523.WqrrWK.small.c25731c6-e071-4f90-bef2-998307289afa.png&key=a19fcc184b9711e1b4764040d3dc5c07"
            }
          }
        })
        subject.to_md[0].should eq(%{__codepen__:\n[![codepen](https://screenshot.codepen.io/3285523.WqrrWK.small.c25731c6-e071-4f90-bef2-998307289afa.png)](https://codepen.io/andriyparashchuk/embed/preview/WqrrWK?height=600&slug-hash=WqrrWK&default-tabs=html,result&host=https://codepen.io)\n[https://codepen.io/andriyparashchuk/pen/WqrrWK?editors=1100](https://codepen.io/andriyparashchuk/pen/WqrrWK?editors=1100)})
      end

      describe "gist" do
        it "render media gist inline" do
          WebMock.stub(:get, "https://medium.com/media/d0aa4300e50ebcf6d244dd91e836bc5f")
            .to_return(
              body: %{<html><script src="https://gist.github.com/miry/d7e8a19eb66734fb69cf8ee4c32095bc.js" charset="utf-8"></script></html>},
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          WebMock.stub(:get, "https://api.github.com/gists/d7e8a19eb66734fb69cf8ee4c32095bc")
            .to_return(
              body: %{
                {"files": {
                  "usage.sh": {
                    "filename": "usage.sh",
                    "type": "application/x-sh",
                    "raw_url": "https://gist.githubusercontent.com/",
                    "content": "#!/usr/bin/env bash\\n\\nmedup -u miry -d ./posts/miry"
                  }
                }}
              },
              headers: HTTP::Headers{"Content-Type" => "application/json; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [],
              "iframe":{
                "mediaResourceId": "d0aa4300e50ebcf6d244dd91e836bc5f",
                "thumbnailUrl": "https://i.embed.ly/1/image?url=https%3A%2F%2Fgithub.githubassets.com%2Fimages%2Fmodules%2Fgists%2Fgist-og-image.png&key=a19fcc184b9711e1b4764040d3dc5c07"
              }
            }
          })
          subject.to_md[0].should contain(%{medup -u miry -d ./posts/miry})
          subject.to_md[0].should contain(%{[usage.sh view raw](https:})
        end

        it "render media gist inline without thumbnailUrl" do
          WebMock.stub(:get, "https://medium.com/media/07153002bfc51e373161166a7c24cb57")
            .to_return(
              body: %{<html><script src="https://gist.github.com/miry/d7e8a19eb66734fb69cf8ee4c32095bc.js" charset="utf-8"></script></html>},
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          WebMock.stub(:get, "https://api.github.com/gists/d7e8a19eb66734fb69cf8ee4c32095bc")
            .to_return(
              body: %{
                {"files": {
                  "usage.sh": {
                    "filename": "usage.sh",
                    "type": "application/x-sh",
                    "raw_url": "https://gist.githubusercontent.com/",
                    "content": "#!/usr/bin/env bash\\n\\nmedup -u miry -d ./posts/miry"
                  }
                }}
              },
              headers: HTTP::Headers{"Content-Type" => "application/json; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [],
              "iframe":{
                "mediaResourceId": "07153002bfc51e373161166a7c24cb57"
              }
            }
          })
          subject.to_md[0].should contain(%{medup -u miry -d ./posts/miry})
          subject.to_md[0].should contain(%{[usage.sh view raw](https:})
        end

        it "render iframe in case missing gist url" do
          WebMock.stub(:get, "https://medium.com/media/brokengist")
            .to_return(
              body: %{<html>Not found</html>},
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [],
              "iframe":{
                "mediaResourceId": "brokengist",
                "thumbnailUrl": "https://i.embed.ly/1/image?url=https%3A%2F%2Fgithub.githubassets.com%2Fimages%2Fmodules%2Fgists%2Fgist-og-image.png&key=a19fcc184b9711e1b4764040d3dc5c07"
              }
            }
          })
          subject.to_md[0].should eq(%{<iframe src="./assets/brokengist.html"></iframe>})
        end
      end

      describe "youtube" do
        it "renders media inline" do
          WebMock.stub(:get, "https://medium.com/media/youtuberesourceid")
            .to_return(
              body: %{
                <html><title>Some title of video – Medium</title>
                <body>
                <iframe
      src="https://cdn.embedly.com/widgets/media.html?url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D30xiI21RraQ&amp;src=https%3A%2F%2Fwww.youtube.com%2Fembed%2F30xiI21RraQ&amp;type=text%2Fhtml&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;schema=youtube"
      allowfullscreen frameborder="0" scrolling="no"></iframe>
                </body>
                </html>
              },
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [], "layout": 1,
              "iframe":{
                "mediaResourceId": "youtuberesourceid",
                "iframeWidth": 854,
                "iframeHeight": 480
              }
            }
          })
          subject.to_md[0].should contain(%{[![Youtube](https://img.youtube.com/vi/30xiI21RraQ/hqdefault.jpg)](https://www.youtube.com/watch?v=30xiI21RraQ)})
        end
      end

      describe "soundcloud" do
        it "renders media inline" do
          WebMock.stub(:get, "https://medium.com/media/soundcloudsourceid")
            .to_return(
              body: %{
                <html><body>
                <iframe src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fw.soundcloud.com%2Fplayer%2F%3Furl%3Dhttps%253A%252F%252Fapi.soundcloud.com%252Ftracks%252F834983812%26show_artwork%3Dtrue&amp;display_name=SoundCloud&amp;url=https%3A%2F%2Fsoundcloud.com%2Flil-jodeci%2Fcrying-is-dead&amp;image=https%3A%2F%2Fi1.sndcdn.com%2Fartworks-WxvfCeEA7YqcN30t-DlA82Q-t500x500.jpg&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;type=text%2Fhtml&amp;schema=soundcloud" allowfullscreen frameborder="0" scrolling="no"></iframe>
                </body></html>
              },
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [], "layout": 1,
              "iframe":{"mediaResourceId": "soundcloudsourceid"}
            }
          })
          subject.to_md[0].should contain(%{[![SoundCloud](https://i1.sndcdn.com/artworks-WxvfCeEA7YqcN30t-DlA82Q-t500x500.jpg)](https://w.soundcloud.com/player/?url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F834983812&show_artwork=true)})
        end
      end

      describe "codepen" do
        it "renders media inline" do
          WebMock.stub(:get, "https://medium.com/media/codepensourceid")
            .to_return(
              body: %{
                <html><body>
                <iframe src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fw.soundcloud.com%2Fplayer%2F%3Furl%3Dhttps%253A%252F%252Fapi.soundcloud.com%252Ftracks%252F834983812%26show_artwork%3Dtrue&amp;display_name=SoundCloud&amp;url=https%3A%2F%2Fsoundcloud.com%2Flil-jodeci%2Fcrying-is-dead&amp;image=https%3A%2F%2Fi1.sndcdn.com%2Fartworks-WxvfCeEA7YqcN30t-DlA82Q-t500x500.jpg&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;type=text%2Fhtml&amp;schema=soundcloud" allowfullscreen frameborder="0" scrolling="no"></iframe>
                </body></html>
              },
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [], "layout": 1,
              "iframe":{"mediaResourceId": "codepensourceid"}
            }
          })
          subject.to_md[0].should contain(%{[![SoundCloud](https://i1.sndcdn.com/artworks-WxvfCeEA7YqcN30t-DlA82Q-t500x500.jpg)](https://w.soundcloud.com/player/?url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F834983812&show_artwork=true)})
        end

        it "renders without display name" do
          WebMock.stub(:get, "https://medium.com/media/codepensourceid_without_name")
            .to_return(
              body: %{
                <html><body>
                <iframe src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fcodepen.io%2Fandriyparashchuk%2Fembed%2Fpreview%2FWqrrWK%3Fheight%3D600%26slug-hash%3DWqrrWK%26default-tabs%3Dhtml%2Cresult%26host%3Dhttps%3A%2F%2Fcodepen.io&amp;url=https%3A%2F%2Fcodepen.io%2Fandriyparashchuk%2Fpen%2FWqrrWK%3Feditors%3D1100&amp;image=https%3A%2F%2Fscreenshot.codepen.io%2F3285523.WqrrWK.small.c25731c6-e071-4f90-bef2-998307289afa.png&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;type=text%2Fhtml&amp;schema=codepen" allowfullscreen frameborder="0" scrolling="no"></iframe>
                </body></html>
              },
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})

          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "d2a9", "type": 11, "text": "", "markups": [], "layout": 1,
              "iframe":{"mediaResourceId": "codepensourceid_without_name"}
            }
          })
          subject.to_md[0].should contain(%{__codepen__:\n[![codepen](https://screenshot.codepen.io/3285523.WqrrWK.small.c25731c6-e071-4f90-bef2-998307289afa.png)](https://codepen.io/andriyparashchuk/embed/preview/WqrrWK?height=600&slug-hash=WqrrWK&default-tabs=html,result&host=https://codepen.io)})
        end
      end

      describe "twitter" do
        it "renders media inline" do
          WebMock.stub(:get, "https://medium.com/media/twittersourceid")
            .to_return(
              body: %{
                <html>
                <head>
                <title>Tweet</title>
                <meta name="description" content="Message *everything*. https://t.co/Z9tzeOkIvQ">
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                </head>
                <body>
                <blockquote class="twitter-tweet" data-conversation="none" data-align="center" data-dnt="true">
                <p>&#x200a;&mdash;&#x200a;
                <a href="https://twitter.com/copyconstruct/status/941461955386122240">@copyconstruct</a></p>
                </blockquote>
                <script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
                </body>
                </html>
              },
              headers: HTTP::Headers{"Content-Type" => "text/html; charset=utf-8"})
          subject = Medium::Post::Paragraph.from_json(%{
            {
              "name": "9169","type": 11,"text": "","markups": [],"layout": 1,
              "iframe": {
                "mediaResourceId": "twittersourceid",
                "iframeWidth": 500, "iframeHeight": 185,
                "thumbnailUrl": "https://i.embed.ly/1/image?url=https%3A%2F%2Fpbs.twimg.com%2Fprofile_images%2F825614963729272832%2FxbeK0wJV_400x400.jpg&key=a19fcc184b9711e1b4764040d3dc5c07"
              }
            }
          })
          subject.to_md[0].should contain(%{> Message *everything*. https://t.co/Z9tzeOkIvQ})
          subject.to_md[0].should contain(%{&#x200a;&mdash;&#x200a;})
          subject.to_md[0].should contain(%{<a href="https://twitter.com/copyconstruct/status/941461955386122240">@copyconstruct</a>})
        end
      end
    end

    it "renders inline code block" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 6, "text": "TL;DR xxd ./bin/app | vim — and :%!xxd -r > ./bin/new_app", "markups": [{"type": 10,"start": 6,"end": 27},{"type": 10,"start": 32,"end": 57}]}})
      subject.to_md[0].should eq("> TL;DR `xxd ./bin/app | vim —` and `:%!xxd -r > ./bin/new_app`")
    end

    it "renders bold link" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 6, "text": "My xxd in the world.", "markups": [{"type": 3, "start": 3,"end": 6, "href": "http://example.com"},{"type": 1,"start": 3,"end": 6}]}})
      subject.to_md[0].should eq("> My [**xxd**](http://example.com) in the world.")
    end

    it "skip render background image" do
      subject = Medium::Post::Paragraph.from_json(%{{"name": "d2a9", "type": 15, "text": "picture by me", "markups": [{"type": 3, "start": 11,"end": 15, "href": "http://example.com", "title": "", "rel": "", "anchorType": 0}]}})
      subject.to_md[0].should eq("")
    end
  end

  describe "#process_youtube_content" do
    it "could not render youtube link for empty content" do
      subject = Medium::Post::Paragraph.from_json(%{{"type": 3, "text": "foo"}})
      subject.process_youtube_content("").should eq("")
    end

    it "could not render youtube link for some text" do
      subject = Medium::Post::Paragraph.from_json(%{{"type": 3, "text": "foo"}})
      subject.process_youtube_content("oops").should eq("")
    end

    it "render youtube link for some text" do
      subject = Medium::Post::Paragraph.from_json(%{{"type": 3, "text": "foo"}})
      content = %{
        <iframe
    src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fwww.youtube.com%2Fembed%2F30xiI21RraQ%3Ffeature%3Doembed&amp;display_name=YouTube&amp;url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D30xiI21RraQ&amp;image=https%3A%2F%2Fi.ytimg.com%2Fvi%2F30xiI21RraQ%2Fhqdefault.jpg&amp;key=a19fcc184b9711e1b4764040d3dc5c07&amp;type=text%2Fhtml&amp;schema=youtube"
    allowfullscreen frameborder="0" scrolling="no"></iframe>
      }
      actual = subject.process_youtube_content(content)
      expected = %{[![Youtube](https://img.youtube.com/vi/30xiI21RraQ/hqdefault.jpg)](https://www.youtube.com/watch?v=30xiI21RraQ)}
      actual.should eq(expected)
    end
  end
end
