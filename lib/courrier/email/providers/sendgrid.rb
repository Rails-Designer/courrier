# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Sendgrid < Base
        ENDPOINT_URL = "https://api.sendgrid.com/v3/mail/send"

        def body
          {
            "from" => address_list(@options.from)&.first,
            "personalizations" => [
              {
                "to" => address_list(@options.to),
                "cc" => address_list(@options.cc),
                "bcc" => address_list(@options.bcc)
              }.compact
            ],
            "reply_to" => address_list(@options.reply_to)&.first,

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

        def default_headers
          {
            "Authorization" => "Bearer #{@api_key}"
          }
        end
      end
    end
  end
end
