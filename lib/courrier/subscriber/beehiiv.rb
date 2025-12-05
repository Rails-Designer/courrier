# frozen_string_literal: true

require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Beehiiv < Base
      ENDPOINT_URL = "https://api.beehiiv.com/v2/publications"

      def create(email)
        publication_id = Courrier.configuration.subscriber[:publication_id]
        raise Courrier::ConfigurationError, "Beehiiv requires `publication_id` in subscriber configuration" unless publication_id

        request(:post, "#{ENDPOINT_URL}/#{publication_id}/subscriptions", {"email" => email})
      end

      def destroy(email)
        publication_id = Courrier.configuration.subscriber[:publication_id]
        raise Courrier::ConfigurationError, "Beehiiv requires `publication_id` in subscriber configuration" unless publication_id

        subscription_id = subscription_id(publication_id, email)
        return Courrier::Subscriber::Result.new(error: StandardError.new("Subscription not found")) unless subscription_id

        request(:delete, "#{ENDPOINT_URL}/#{publication_id}/subscriptions/#{subscription_id}")
      end

      private

      def subscription_id(publication_id, email)
        response = request(:get, "#{ENDPOINT_URL}/#{publication_id}/subscriptions?email=#{email}")

        return nil unless response.success?

        response.data.dig("data", 0, "id")
      end

      def headers
        {
          "Authorization" => "Bearer #{@api_key}",
          "Content-Type" => "application/json"
        }
      end
    end
  end
end
