# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Cloudflare < Base
        def body
          {
            "from" => @options.from,
            "to" => @options.to,
            "reply_to" => @options.reply_to,
            "cc" => @options.cc,
            "bcc" => @options.bcc,
            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def endpoint_url
          account_id = @provider_options.account_id
          raise Courrier::ArgumentError, "Cloudflare requires an `account_id`" unless account_id

          "https://api.cloudflare.com/client/v4/accounts/#{account_id}/email/sending/send"
        end

        def default_headers
          {"Authorization" => "Bearer #{@api_key}"}
        end
      end
    end
  end
end
