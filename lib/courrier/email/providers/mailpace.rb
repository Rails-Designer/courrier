# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailpace < Base
        ENDPOINT_URL = "https://app.mailpace.com/api/v1/send"

        def body
          {
            "from" => @options.from,

            "to" => @options.to,
            "replyto" => @options.reply_to,

            "subject" => @options.subject,
            "textbody" => @options.text,
            "htmlbody" => @options.html
          }.compact
        end

        private

        def headers
          {
            "MailPace-Server-Token" => @api_key
          }
        end
      end
    end
  end
end
