# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Cloudflare < Base
        def self.config_options = %w[account_id]

        def body
          {
            "from" => recipients(@options.from)&.first,
            "to" => recipients(@options.to),
            "reply_to" => address_list(@options.reply_to, as: :plain)&.first,
            "cc" => recipients(@options.cc),
            "bcc" => recipients(@options.bcc),
            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def recipients(value)
          address_list(value, as: :plain)&.map { |address| email_and_name(address, email_key: "address") }
        end

        def endpoint_url
          account_id = @provider_options.account_id
          raise Courrier::ArgumentError, "Cloudflare requires an `account_id`" unless account_id

          "https://api.cloudflare.com/client/v4/accounts/#{account_id}/email/sending/send"
        end

        def default_headers
          {"Authorization" => "Bearer #{@api_key}"}
        end
      end
    end
  end
end
