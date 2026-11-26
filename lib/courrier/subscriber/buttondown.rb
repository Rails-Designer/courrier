# frozen_string_literal: true

require "uri"
require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Buttondown < Base
      ENDPOINT_URL = "https://api.buttondown.email/v1/subscribers"

      # The version that renamed `email` to `email_address`. Newsletters can be
      # pinned to an older one, so it is sent along with the new field name.
      API_VERSION = "2024-08-01"

      def create(email)
        request(:post, ENDPOINT_URL, {"email_address" => email}, {"X-API-Version" => API_VERSION})
      end

      def destroy(email)
        request(:delete, "#{ENDPOINT_URL}/#{URI.encode_www_form_component(email)}")
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
