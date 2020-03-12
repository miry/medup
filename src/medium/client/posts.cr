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
