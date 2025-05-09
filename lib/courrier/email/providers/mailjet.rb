# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailjet < Base
        ENDPOINT_URL = "https://api.mailjet.com/v3.1/send"

        def body
          {
            "Messages" => [
              {
                "From" => {
                  "Email" => @options.from
                },

                "To" => [
                  {
                    "Email" => @options.to
                  }
                ],
                "ReplyTo" => reply_to_object,

                "Subject" => @options.subject,
                "TextPart" => @options.text,
                "HTMLPart" => @options.html
              }.compact
            ]
          }
        end

        private

        def headers
          {
            "Authorization" => "Basic " + Base64.strict_encode64("#{@api_key}:#{@provider_options.api_secret}")
          }
        end

        def reply_to_object
          return if @options.reply_to.nil?

          {
            "Email" => @options.reply_to
          }
        end
      end
    end
  end
end
