# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailersend < Base
        ENDPOINT_URL = "https://api.mailersend.com/v1/email"

        def body
          {
            "from" => address_list(@options.from)&.first,
            "to" => address_list(@options.to),
            "cc" => address_list(@options.cc),
            "bcc" => address_list(@options.bcc),
            "reply_to" => address_list(@options.reply_to)&.first,
            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def default_headers = {"Authorization" => "Bearer #{@api_key}"}
      end
    end
  end
end
