# frozen_string_literal: true

require "courrier/email/request"

module Courrier
  class Email
    module Providers
      class Base
        def initialize(api_key: nil, options: {}, provider_options: {})
          @api_key = api_key
          @options = options
          @provider_options = provider_options
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

        def headers = {}

        def provider = self.class.name.split("::").last
      end
    end
  end
end
