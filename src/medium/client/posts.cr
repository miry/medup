module Medium
  class Client
    module Posts
      def posts
        u = user
        user_id = u["user"]["userId"]

        records = get("/_/api/users/#{user_id}/profile/stream")["payload"]["references"]["Post"]

        result = [] of Hash(String, JSON::Any)
        records.raw.as(Hash).each do |k, post|
          result << post.raw.as(Hash)
        end
        result
      end
    end
  end
end
