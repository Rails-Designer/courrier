# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Resend < Base
        ENDPOINT_URL = "https://api.resend.com/emails"

        def body
          {
            "from" => @options.from,
            "to" => @options.to,
            "reply_to" => @options.reply_to,
            "cc" => @options.cc,
            "bcc" => @options.bcc,
            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def headers
          {
            "Authorization" => "Bearer #{@api_key}"
          }
        end
      end
    end
  end
end
