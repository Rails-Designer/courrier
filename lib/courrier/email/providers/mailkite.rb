# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailkite < Base
        ENDPOINT_URL = "https://api.mailkite.dev/v1/send"

        def body
          {
            "from" => @options.from,
            "to" => addresses(@options.to),
            "cc" => addresses(@options.cc),
            "bcc" => addresses(@options.bcc),
            "replyTo" => @options.reply_to,
            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def default_headers
          {
            "Authorization" => "Bearer #{@api_key}"
          }
        end

        def addresses(value)
          list = value&.to_s&.split(",")&.map(&:strip)&.reject(&:empty?)

          list&.empty? ? nil : list
        end
      end
    end
  end
end
