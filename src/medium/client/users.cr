module Medium
  class Client
    module Users
      # https://github.com/Medium/medium-api-docs#31-users
      def me
        get "/v1/me"
      end
    end
  end
end
