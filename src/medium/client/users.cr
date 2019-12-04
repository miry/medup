module Medium
  class Client
    module Users
      # https://github.com/Medium/medium-api-docs#31-users
      def user
        raise "require user" if @user.nil?
        get("/@#{@user}")["payload"]
      end
    end
  end
end
