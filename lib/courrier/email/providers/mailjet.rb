# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailjet < Base
        def self.config_options = %w[api_secret]

        ENDPOINT_URL = "https://api.mailjet.com/v3.1/send"

        def body
          {
            "Messages" => [
              {
                "From" => {
                  "Email" => @options.from
                },

                "To" => addresses(@options.to),
                "Cc" => addresses(@options.cc),
                "Bcc" => addresses(@options.bcc),
                "ReplyTo" => reply_to_object,

                "Subject" => @options.subject,
                "TextPart" => @options.text,
                "HTMLPart" => @options.html
              }.compact
            ]
          }
        end

        private

        def default_headers
          {
            "Authorization" => "Basic #{["#{@api_key}:#{@provider_options.api_secret}"].pack("m0")}"
          }
        end

        def addresses(value)
          address_list(value, as: :plain)&.map { |address| {"Email" => address} }
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
