module Medium
  class Client
    module Users
      # https://github.com/Medium/medium-api-docs#31-users
      def user
        get("/@#{user}")["payload"]
      end
    end
  end
end
