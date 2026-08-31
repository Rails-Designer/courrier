# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailkite < Base
        ENDPOINT_URL = "https://api.mailkite.dev/v1/send"

        def body
          {
            "from" => @options.from,
            "to" => address_list(@options.to, as: :plain),
            "cc" => address_list(@options.cc, as: :plain),
            "bcc" => address_list(@options.bcc, as: :plain),
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
      end
    end
  end
end
