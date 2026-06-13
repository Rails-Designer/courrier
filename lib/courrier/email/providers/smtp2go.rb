# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Smtp2go < Base
        ENDPOINT_URL = "https://api.smtp2go.com/v3/email/send"

        def body
          {
            "sender" => @options.from,
            "to" => @options.to.to_s.split(",").map(&:strip),
            "cc" => @options.cc&.split(",")&.map(&:strip),
            "bcc" => @options.bcc&.split(",")&.map(&:strip),
            "subject" => @options.subject,
            "html_body" => @options.html,
            "text_body" => @options.text
          }.compact
        end

        private

        def default_headers
          { "X-Smtp2go-Api-Key" => @api_key }
        end
      end
    end
  end
end
