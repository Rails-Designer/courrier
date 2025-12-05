# frozen_string_literal: true

require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Mailchimp < Base
      def create(email)
        dc = Courrier.configuration.subscriber[:dc]
        list_id = Courrier.configuration.subscriber[:list_id]

        raise Courrier::ConfigurationError, "Mailchimp requires `dc` and `list_id` in subscriber configuration" unless dc && list_id

        request(:post, "https://#{dc}.api.mailchimp.com/3.0/lists/#{list_id}/members", {
          "email_address" => email,
          "status" => "subscribed"
        })
      end

      def destroy(email)
        dc = Courrier.configuration.subscriber[:dc]
        list_id = Courrier.configuration.subscriber[:list_id]

        raise Courrier::ConfigurationError, "Mailchimp requires `dc` and `list_id` in subscriber configuration" unless dc && list_id

        request(:delete, "https://#{dc}.api.mailchimp.com/3.0/lists/#{list_id}/members/#{email}")
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
