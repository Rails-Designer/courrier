# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Ses < Base
        def self.config_options = %w[region access_key_id secret_access_key session_token]

        def deliver
          uri = URI.parse("https://email.#{@provider_options[:region]}.amazonaws.com/v2/email/outbound-emails")

          request = Net::HTTP::Post.new(uri)
          default_headers.merge(@custom_headers).each { |name, value| request[name] = value }

          sign!(request)

          request.body = JSON.dump(body)

          options = {use_ssl: uri.scheme == "https"}
          response = Net::HTTP.start(uri.hostname, uri.port, options) { it.request(request) }

          Courrier::Email::Result.new(response: response)
        rescue => error
          Courrier::Email::Result.new(error: error)
        end

        def body
          {
            "FromEmailAddress" => @options.from,
            "Destination" => {
              "ToAddresses" => Array(@options.to),
              "CcAddresses" => @options.cc ? Array(@options.cc) : nil,
              "BccAddresses" => @options.bcc ? Array(@options.bcc) : nil
            }.compact,

            "ReplyToAddresses" => @options.reply_to ? Array(@options.reply_to) : nil,
            "Content" => {
              "Simple" => {
                "Subject" => {"Data" => @options.subject},

                "Body" => {
                  "Text" => {"Data" => @options.text},
                  "Html" => {"Data" => @options.html}
                }.compact
              }
            }
          }.compact
        end

        private

        def default_headers
          {
            "Content-Type" => "application/json",
            "Accept" => "application/json"
          }
        end

        def sign!(request)
          require "aws-sigv4"

          Aws::Sigv4::Signer.new(
            service: "ses",
            region: @provider_options[:region],
            access_key_id: @provider_options[:access_key_id],
            secret_access_key: @provider_options[:secret_access_key],
            session_token: @provider_options[:session_token]
          ).sign_request(
            http_method: request.method,
            url: request.uri.to_s,
            headers: request.to_hash
          ).headers.each { |name, value| request[name] = value }
        end
      end
    end
  end
end
