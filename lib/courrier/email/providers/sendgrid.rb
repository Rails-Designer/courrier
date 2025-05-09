# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Sendgrid < Base
        ENDPOINT_URL = "https://api.sendgrid.com/v3/mail/send"

        def body
          {
            "from" => {
              "email" => @options.from
            },
            "personalizations" => [
              {
                "to" => [
                  {
                    "email" => @options.to
                  }
                ]
              }
            ],
            "reply_to" => reply_to_object,

            "subject" => @options.subject,
            "content" => [
              {
                "type" => "text/plain",
                "value" => @options.text
              },
              {
                "type" => "text/html",
                "value" => @options.html
              }
            ].compact
          }.compact
        end

        private

        def headers
          {
            "Authorization" => "Bearer #{@api_key}"
          }
        end

        def reply_to_object
          return if @options.reply_to.nil?

          {
            "email" => @options.reply_to
          }
        end
      end
    end
  end
end
