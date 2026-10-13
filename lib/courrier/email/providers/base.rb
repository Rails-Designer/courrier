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
          list = split_addresses(value).map(&:strip).reject(&:empty?)
          return if list.empty?

          list.map { |address| address_element(address, as) }
        end

        def address_line(value) = address_list(value, as: :plain)&.join(", ")

        def split_addresses(value)
          value.to_s.scan(/(?:"(?:\\.|[^"\\])*"|[^,])+/)
        end

        def address_element(address, as)
          case as
          when :email then email_and_name(address)
          when :address then {"address" => address}
          else address
          end
        end

        # JSON APIs take the display name of `Name <email>` in a field of its own and reject it in the email field
        def email_and_name(address, email_key: "email", name_key: "name")
          match = address.match(/\A(?<name>.*?)\s*<(?<email>[^<>]+)>\z/m)
          return {email_key => address} unless match

          name = unquote(match[:name].strip)

          {email_key => match[:email].strip, name_key => (name unless name.empty?)}.compact
        end

        def unquote(name)
          return name unless name.length >= 2 && name.start_with?('"') && name.end_with?('"')

          name[1..-2].gsub(/\\(.)/m, '\1')
        end

        def provider = self.class.name.split("::").last
      end
    end
  end
end
