# frozen_string_literal: true

require "uri"
require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Brevo < Base
      ENDPOINT_URL = "https://api.brevo.com/v3/contacts"

      def create(email)
        body = {
          "email" => email,
          "updateEnabled" => true
        }

        list_ids = Array(Courrier.configuration.subscriber[:list_ids]).compact
        body["listIds"] = list_ids unless list_ids.empty?

        request(:post, ENDPOINT_URL, body)
      end

      def destroy(email)
        identifier = URI.encode_www_form_component(email)

        request(:delete, "#{ENDPOINT_URL}/#{identifier}")
      end

      private

      def headers
        {
          "api-key" => @api_key,
          "Content-Type" => "application/json"
        }
      end
    end
  end
end
