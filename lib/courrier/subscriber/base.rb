# frozen_string_literal: true

require "courrier/subscriber/result"

module Courrier
  class Subscriber
    class Base
      def initialize(api_key:)
        @api_key = api_key
      end

      def create(email)
        raise NotImplementedError
      end

      def destroy(email)
        raise NotImplementedError
      end

      private

      def request(method, url, body = nil)
        uri = URI(url)
        request_class = case method
        when :post then Net::HTTP::Post
        when :delete then Net::HTTP::Delete
        when :put then Net::HTTP::Put
        when :patch then Net::HTTP::Patch
        when :get then Net::HTTP::Get
        end

        request = request_class.new(uri)
        request.body = body.to_json if body

        headers.each { |key, value| request[key] = value }

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        Courrier::Subscriber::Result.new(response: response)
      rescue => error
        Courrier::Subscriber::Result.new(error: error)
      end

      def headers
        raise NotImplementedError
      end
    end
  end
end
