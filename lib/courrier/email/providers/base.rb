# frozen_string_literal: true

require "courrier/email/request"

module Courrier
  class Email
    module Providers
      class Base
        def self.config_options = []

        def initialize(api_key: nil, options: {}, provider_options: {}, context_options: {}, custom_headers: {})
          @api_key = api_key
          @options = options
          @provider_options = provider_options
          @context_options = context_options
          @custom_headers = custom_headers
        end

        def deliver
          Request.new(
            endpoint_url: endpoint_url,
            body: body,
            provider: provider,
            headers: headers,
            content_type: content_type
          ).post
        end

        def body = raise Courrier::NotImplementedError, "Provider class must implement `body`"

        private

        def endpoint_url = self.class::ENDPOINT_URL

        def content_type = "application/json"

        def headers
          default_headers.merge(@custom_headers)
        end

        def default_headers = {}

        def address_list(value, as: :email)
          list = value&.to_s&.split(",")&.map(&:strip)&.reject(&:empty?)
          return unless list && !list.empty?

          list.map { |address| address_element(address, as) }
        end

        def address_element(address, as)
          case as
          when :email then {"email" => address}
          when :address then {"address" => address}
          else address
          end
        end

        def provider = self.class.name.split("::").last
      end
    end
  end
end
