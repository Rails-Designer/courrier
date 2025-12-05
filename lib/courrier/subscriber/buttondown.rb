# frozen_string_literal: true

require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Buttondown < Base
      ENDPOINT_URL = "https://api.buttondown.email/v1/subscribers"

      def create(email)
        request(:post, ENDPOINT_URL, {"email" => email})
      end

      def destroy(email)
        request(:delete, "#{ENDPOINT_URL}/#{email}")
      end

      private

      def headers
        {
          "Authorization" => "Token #{@api_key}",
          "Content-Type" => "application/json"
        }
      end
    end
  end
end
