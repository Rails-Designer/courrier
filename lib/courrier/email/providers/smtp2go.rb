# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Smtp2go < Base
        ENDPOINT_URL = "https://api.smtp2go.com/v3/email/send"

        def body
          {
            "sender" => @options.from,
            "to" => address_list(@options.to, as: :plain),
            "cc" => address_list(@options.cc, as: :plain),
            "bcc" => address_list(@options.bcc, as: :plain),
            "subject" => @options.subject,
            "html_body" => @options.html,
            "text_body" => @options.text,
            "custom_headers" => reply_to_header
          }.compact
        end

        private

        def reply_to_header
          return unless (reply_to = address_line(@options.reply_to))

          [{"header" => "Reply-To", "value" => reply_to}]
        end

        def default_headers
          {"X-Smtp2go-Api-Key" => @api_key}
        end
      end
    end
  end
end
