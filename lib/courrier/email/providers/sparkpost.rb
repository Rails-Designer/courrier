# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Sparkpost < Base
        ENDPOINT_URL = "https://api.sparkpost.com/api/v1/transmissions"

        def body
          {
            "content" => {
              "reply_to" => @options.reply_to,
              "from" => @options.from,
              "subject" => @options.subject,
              "text" => @options.text,
              "html" => @options.html,
              "headers" => cc_header
            }.compact,
            "recipients" => recipients
          }
        end

        private

        def default_headers
          {
            "Authorization" => @api_key
          }
        end

        # SparkPost has no cc/bcc field: every copy is an entry in `recipients`, and only
        # the addresses repeated in the CC header are shown as copied. `header_to` keeps the
        # visible To line the same for all of them, so a bcc stays hidden and a cc is not
        # mistaken for a to.
        def recipients
          [@options.to, @options.cc, @options.bcc].flat_map { |value| recipients_for(value) }
        end

        def recipients_for(value)
          Array(address_list(value, as: :plain)).map do |address|
            {"address" => {"email" => address, "header_to" => address_line(@options.to)}}
          end
        end

        def cc_header
          cc = address_line(@options.cc)

          {"CC" => cc} if cc
        end
      end
    end
  end
end
