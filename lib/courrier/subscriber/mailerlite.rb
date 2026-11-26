# frozen_string_literal: true

require "uri"
require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Mailerlite < Base
      ENDPOINT_URL = "https://connect.mailerlite.com/api/subscribers"

      def create(email)
        request(:post, ENDPOINT_URL, {"email" => email})
      end

      def destroy(email)
        # Deleting requires the subscriber id; only the lookup accepts an email
        lookup = request(:get, "#{ENDPOINT_URL}/#{URI.encode_www_form_component(email)}")
        return lookup unless lookup.success?

        request(:delete, "#{ENDPOINT_URL}/#{lookup.data.dig("data", "id")}")
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
