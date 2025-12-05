# frozen_string_literal: true

require "courrier/subscriber/base"

module Courrier
  class Subscriber
    class Loops < Base
      ENDPOINT_URL = "https://app.loops.so/api/v1/contacts"

      def create(email)
        request(:post, "#{ENDPOINT_URL}/create", {
          "email" => email
        })
      end

      def destroy(email)
        request(:post, "#{ENDPOINT_URL}/delete", {
          "email" => email
        })
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
