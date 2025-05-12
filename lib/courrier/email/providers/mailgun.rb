# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Mailgun < Base
        ENDPOINT_URL = "https://api.mailgun.net/v3/%{domain}/messages"

        def body
          {
            "from" => @options.from,

            "to" => @options.to,
            "h:Reply-To" => @options.reply_to,

            "subject" => @options.subject,
            "text" => @options.text,
            "html" => @options.html
          }.compact
        end

        private

        def endpoint_url
          domain = @provider_options.domain || raise(Courrier::ArgumentError, "Mailgun requires a `domain`")

          ENDPOINT_URL % {domain: domain}
        end

        def content_type = "multipart/form-data"

        def headers
          {
            "Authorization" => "Basic #{Base64.strict_encode64("api:#{@api_key}")}"
          }
        end
      end
    end
  end
end
