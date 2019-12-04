module Medium
  class Client
    module Collections
      def collection(collection : String)
        get "/#{collection}"
      end
    end
  end
end
