# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Brevo < Base
        ENDPOINT_URL = "https://api.brevo.com/v3/smtp/email"

        def body
          {
            "sender" => email_address(@options.from),
            "to" => email_addresses(@options.to),
            "cc" => email_addresses(@options.cc),
            "bcc" => email_addresses(@options.bcc),
            "replyTo" => email_address(@options.reply_to),
            "subject" => @options.subject,
            "htmlContent" => @options.html,
            "textContent" => @options.text
          }.compact
        end

        private

        def default_headers = {"api-key" => @api_key}

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
