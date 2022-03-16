module Medium
  class Client
    module Posts
      def posts(source = "overview")
        u = user
        user_id = u["user"]["userId"]
        result = [] of Hash(String, JSON::Any)

        params : Hash(String, String)? = {"limit" => "100", "source" => source}
        stream_url = "/_/api/users/#{user_id}/profile/stream"
        while params
          response = get(stream_url, params: params)
          records = response["payload"]["references"]["Post"]

          records.raw.as(Hash).each do |k, post|
            result << post.raw.as(Hash)
          end

          next_page = response["payload"]["paging"]["next"]?
          break if next_page.nil?

          params["page"] = next_page["page"].raw.to_s
          params["to"] = next_page["to"].raw.to_s
        end

        result
      end

      def streams(source = "overview")
        u = user
        user_id = u["user"]["userId"]
        result = [] of String

        params : Hash(String, String)? = {"limit" => "100", "source" => source}
        stream_url = "/_/api/users/#{user_id}/profile/stream"
        while params
          response = get(stream_url, params: params)
          records = response["payload"]["streamItems"]

          records.raw.as(Array).each do |post|
            post_preview = post.raw.as(Hash)
            if post_preview["itemType"] == "postPreview"
              post_id = post["postPreview"]["postId"].raw.as(String)
              result << post_id_to_url(post_id)
            end
          end

          next_page = response["payload"]["paging"]["next"]?
          break if next_page.nil?

          params["page"] = next_page["page"].raw.to_s
          params["to"] = next_page["to"].raw.to_s
        end

        result
      end

      # Publication home page. Returns only favorite articles
      def collection_stream
        p = publication
        publication_id = p["collection"]["id"]
        params : Hash(String, String)? = Hash(String, String).new
        stream_url = "/_/api/collections/#{publication_id}/stream"
        result = [] of String
        while params
          response = get(stream_url, params: params)

          references = response["payload"]["references"]

          if references.has_key?("Post")
            records = references["Post"]

            records.raw.as(Hash).each do |post_id, post|
              result << post_id_to_url(post_id)
            end
          end

          next_page = response["payload"]["paging"]["next"]?
          break if next_page.nil?

          params["page"] = next_page["page"].raw.to_s
          params["to"] = next_page["to"].raw.to_s
        end

        result
      end

      # A list of all posts from publications
      def collection_archive(year : String = "", month : String = "", day : String = "") : Array(String)
        params : Hash(String, String)? = Hash(String, String).new
        stream_url = "/#{@publication}/archive"
        if year != ""
          stream_url += "/#{year}"
          if month != ""
            stream_url += "/#{month}"
            stream_url += "/#{day}" if day != ""
          end
        end
        result = [] of String
        response = get(stream_url, params: params)

        references = response["payload"]["references"].raw.as(Hash)

        if references.has_key?("Post")
          records = references["Post"]

          records.raw.as(Hash).each do |post_id, post|
            result << post_id_to_url(post_id)
          end
        end

        if year.empty?
          bucket = response["payload"]["archiveIndex"]["yearlyBuckets"].raw.as(Array)
          bucket.each do |year_bucket|
            next if year_bucket["hasStories"] != true
            result += collection_archive(year_bucket["year"].raw.as(String))
          end
        else
          if month.empty?
            bucket = response["payload"]["archiveIndex"]["monthlyBuckets"].raw.as(Array)
            bucket.each do |month_bucket|
              next if month_bucket["hasStories"] != true
              result += collection_archive(month_bucket["year"].raw.as(String),
                month_bucket["month"].raw.as(String))
            end
          else
            if day.empty?
              bucket = response["payload"]["archiveIndex"]["dailyBuckets"].raw.as(Array)
              bucket.each do |day_bucket|
                next if day_bucket["hasStories"] != true
                result += collection_archive(
                  day_bucket["year"].raw.as(String),
                  day_bucket["month"].raw.as(String),
                  day_bucket["day"].raw.as(String))

              end
            end
          end
        end

        result.uniq
      end

      def post_by_id(post_id : String)
        self.post_by_url(post_id_to_url(post_id))
      end

      def post_by_url(url : String)
        response = get(url)

        result = Post.from_json(response["payload"]["value"].to_json)
        result.url = url

        creator_id = response["payload"]["value"]["creatorId"].as_s
        result.user = User.from_json(response["payload"]["references"]["User"][creator_id].to_json)

        result
      end

      private def post_id_to_url(post_id : String)
        "https://medium.com/@#{@user}/#{post_id}"
      end
    end
  end
end
