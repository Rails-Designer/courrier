# frozen_string_literal: true

module Courrier
  class Subscriber
    class Result
      attr_reader :success, :response, :data, :error

      def initialize(response: nil, error: nil)
        @response = response
        @error = error
        @data = parsed(@response&.body)
        @success = successful?
      end

      def success? = @success

      private

      def parsed(body)
        return {} if @response.nil?

        begin
          JSON.parse(body)
        rescue JSON::ParserError
          {}
        end
      end

      def successful?
        return false if response_failed?
        return @data["success"] if @data.key?("success")

        (200..299).cover?(status_code)
      end

      def response_failed? = @error || @response.nil?

      def status_code = @response.code.to_i
    end
  end
end
