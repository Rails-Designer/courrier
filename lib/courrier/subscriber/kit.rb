# frozen_string_literal: true

require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Kit < Base
      ENDPOINT_URL = "https://api.convertkit.com/v3/forms"

      def create(email)
        form_id = Courrier.configuration.subscriber[:form_id]
        raise Courrier::ConfigurationError, "Kit requires `form_id` in subscriber configuration" unless form_id

        request(:post, "#{ENDPOINT_URL}/#{form_id}/subscribe", {
          "api_key" => @api_key,
          "email" => email
        })
      end

      def destroy(email)
        request(:put, "https://api.convertkit.com/v3/unsubscribe", {
          "api_secret" => @api_key,
          "email" => email
        })
      end

      private

      def headers
        {
          "Content-Type" => "application/json"
        }
      end
    end
  end
end
