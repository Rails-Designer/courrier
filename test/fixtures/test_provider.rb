require "courrier/email/provider"

module Courrier
  class Email
    module Providers
      class TestProvider < Base
        ENDPOINT_URL = "https://railsdesigner.com/api"

        def body
          {test: "data"}
        end
      end
    end
  end
end
