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
            "to" => address_list(@options.to, as: :plain),
            "cc" => address_list(@options.cc, as: :plain),
            "bcc" => address_list(@options.bcc, as: :plain),
            "reply_to" => address_list(@options.reply_to, as: :plain),
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
