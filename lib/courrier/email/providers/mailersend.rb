# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailersend < Base
        ENDPOINT_URL = "https://api.mailersend.com/v1/email"

        def body
          {
            "from" => email_address(@options.from),
            "to" => email_addresses(@options.to),
            "cc" => email_addresses(@options.cc),
            "bcc" => email_addresses(@options.bcc),
            "reply_to" => email_address(@options.reply_to),
            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def default_headers = {"Authorization" => "Bearer #{@api_key}"}

        def email_addresses(addresses)
          addresses&.split(",")&.map { |address| email_address(address) }
        end

        def email_address(address)
          {"email" => address.strip} if address
        end
      end
    end
  end
end
