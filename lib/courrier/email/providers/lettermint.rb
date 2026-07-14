# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Lettermint < Base
        def self.config_options = %w[route]

        ENDPOINT_URL = "https://api.lettermint.co/v1/send"

        def body
          {
            "route" => @provider_options.route,
            "from" => @options.from,
            "to" => @options.to.to_s.split(",").map(&:strip),
            "cc" => @options.cc&.split(",")&.map(&:strip),
            "bcc" => @options.bcc&.split(",")&.map(&:strip),
            "reply_to" => @options.reply_to&.split(",")&.map(&:strip),
            "subject" => @options.subject,
            "html" => @options.html,
            "text" => @options.text
          }.compact
        end

        private

        def default_headers
          {"x-lettermint-token" => @api_key}
        end
      end
    end
  end
end
