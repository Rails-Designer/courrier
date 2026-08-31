# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Brevo < Base
        ENDPOINT_URL = "https://api.brevo.com/v3/smtp/email"

        def body
          {
            "sender" => address_list(@options.from)&.first,
            "to" => address_list(@options.to),
            "cc" => address_list(@options.cc),
            "bcc" => address_list(@options.bcc),
            "replyTo" => address_list(@options.reply_to)&.first,
            "subject" => @options.subject,
            "htmlContent" => @options.html,
            "textContent" => @options.text
          }.compact
        end

        private

        def default_headers = {"api-key" => @api_key}
      end
    end
  end
end
