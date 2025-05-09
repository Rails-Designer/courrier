# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Postmark < Base
        ENDPOINT_URL = "https://api.postmarkapp.com/email"

        def body
          {
            "From" => @options.from,

            "To" => @options.to,
            "ReplyTo" => @options.reply_to,

            "Subject" => @options.subject,
            "TextBody" => @options.text,
            "HtmlBody" => @options.html,

            "MessageStream" => @provider_options.message_stream || "outbound"
          }.compact
        end

        private

        def headers
          {
            "X-Postmark-Server-Token" => @api_key
          }
        end
      end
    end
  end
end
