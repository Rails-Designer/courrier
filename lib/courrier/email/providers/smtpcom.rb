# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Smtpcom < Base
        def self.config_options = %w[channel]

        ENDPOINT_URL = "https://api.smtp.com/v4/messages"

        def body
          {
            "channel" => channel,
            "recipients" => {
              "to" => email_addresses(@options.to),
              "cc" => email_addresses(@options.cc),
              "bcc" => email_addresses(@options.bcc)
            }.compact,
            "originator" => {
              "from" => email_address(@options.from),
              "reply_to" => email_address(@options.reply_to)
            }.compact,
            "subject" => @options.subject,
            "body" => {"parts" => parts}
          }
        end

        private

        def default_headers
          {"Authorization" => "Basic #{base64("api:#{@api_key}")}"}
        end

        def channel
          @provider_options.channel || raise(Courrier::ArgumentError, "SMTP.com requires a `channel`")
        end

        def parts
          [part("text/plain", @options.text), part("text/html", @options.html)].compact
        end

        def part(type, content)
          return unless content

          {
            "type" => type,
            "charset" => "UTF-8",
            "encoding" => "base64",
            "content" => base64(content)
          }
        end

        def base64(value) = [value].pack("m0")

        def email_addresses(addresses)
          addresses&.split(",")&.map { |address| email_address(address) }
        end

        def email_address(address)
          {"address" => address.strip} if address
        end
      end
    end
  end
end
