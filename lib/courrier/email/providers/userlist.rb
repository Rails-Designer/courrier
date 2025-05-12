# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Userlist < Base
        ENDPOINT_URL = "https://push.userlist.com/messages"

        def body
          {
            "from" => @options.from,
            "to" => @options.to,
            "subject" => @options.subject,
            "body" => body_document
          }.compact.merge(provider_options)
        end

        private

        def headers
          {
            "Authorization" => "Push #{@api_key}"
          }
        end

        def body_document
          if @options.html && @options.text
            multipart_document
          elsif @options.html
            html_document
          elsif @options.text
            text_document
          end
        end

        def text_document
          {
            "type" => "text",
            "content" => @options.text
          }
        end

        def html_document
          {
            "type" => "html",
            "content" => @options.html
          }
        end

        def multipart_document
          {
            "type" => "multipart",
            "content" => [
              html_document,
              text_document
            ]
          }
        end

        def provider_options
          {"theme" => nil}.merge(@provider_options)
        end
      end
    end
  end
end
