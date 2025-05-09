# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Sparkpost < Base
        ENDPOINT_URL = "https://api.sparkpost.com/api/v1/transmissions"

        def body
          {
            "content" => {
              "reply_to" => @options.reply_to,
              "from" => @options.from,
              "subject" => @options.subject,
              "text" => @options.text,
              "html" => @options.html
            }.compact,
            "recipients" => [
              {
                "address" => {
                  "email" => @options.to
                }
              }
            ]
          }
        end

        private

        def headers
          {
            "Authorization" => @api_key
          }
        end
      end
    end
  end
end
