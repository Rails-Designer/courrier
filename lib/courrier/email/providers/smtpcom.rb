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
              "to" => address_list(@options.to, as: :address),
              "cc" => address_list(@options.cc, as: :address),
              "bcc" => address_list(@options.bcc, as: :address)
            }.compact,
            "originator" => {
              "from" => address_list(@options.from, as: :address)&.first,
              "reply_to" => address_list(@options.reply_to, as: :address)&.first
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
      end
    end
  end
end
