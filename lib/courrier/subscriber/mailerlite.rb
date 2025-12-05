# frozen_string_literal: true

require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Mailerlite < Base
      ENDPOINT_URL = "https://connect.mailerlite.com/api/subscribers"

      def create(email)
        request(:post, ENDPOINT_URL, {"email" => email})
      end

      def destroy(email)
        request(:delete, "#{ENDPOINT_URL}/#{email}")
      end

      private

      def headers
        {
          "Authorization" => "Bearer #{@api_key}",
          "Content-Type" => "application/json"
        }
      end
    end
  end
end
