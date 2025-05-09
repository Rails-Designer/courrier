# frozen_string_literal: true

require "json"
require "net/http"
require "courrier/email/result"

module Courrier
  class Email
    class Request
      def initialize(endpoint_url:, body:, provider:, headers: {}, content_type: "application/json")
        @endpoint_url = endpoint_url
        @body = body
        @provider = provider
        @headers = headers
        @content_type = content_type
      end

      def post
        uri = URI.parse(@endpoint_url)
        request = Net::HTTP::Post.new(uri)

        headers_for request
        body_for request

        options = {use_ssl: uri.scheme == "https"}

        begin
          response = Net::HTTP.start(uri.hostname, uri.port, options) { _1.request(request) }

          Result.new(response: response)
        rescue => error
          Result.new(error: error)
        end
      end

      private

      def headers_for(request)
        default_headers.merge(@headers).each do |key, value|
          request[key] = value
        end
      end

      def body_for(request)
        if requires_multipart_form?
          set_multipart_form(request)
        else
          set_json_body(request)
        end
      end

      def default_headers
        {
          "Content-Type" => @content_type,
          "Accept" => "application/json"
        }
      end

      def requires_multipart_form?
        ["Mailgun"].include?(@provider)
      end

      def set_multipart_form(request)
        request.set_form(@body, "multipart/form-data")
      end

      def set_json_body(request)
        request.content_type = "application/json"
        request.body = JSON.dump(@body)
      end
    end
  end
end
