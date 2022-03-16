module Medium
  class Client
    module Publications
      def publication
        raise "require publication" if @publication.nil?
        get("/#{@publication}")["payload"]
      end
    end
  end
end
