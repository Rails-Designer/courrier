# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Resend < Base
        ENDPOINT_URL = "https://api.resend.com/emails"

        def body
          {
            "from" => @options.from,
            "to" => address_list(@options.to, as: :plain),
            "reply_to" => address_list(@options.reply_to, as: :plain),
            "cc" => address_list(@options.cc, as: :plain),
            "bcc" => address_list(@options.bcc, as: :plain),
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
