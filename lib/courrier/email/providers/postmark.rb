# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Postmark < Base
        def self.config_options = %w[message_stream template_alias template_id]

        EMAIL_ENDPOINT = "https://api.postmarkapp.com/email"
        TEMPLATE_ENDPOINT = "https://api.postmarkapp.com/email/withTemplate"

        def body
          template? ? template_body : standard_body
        end

        private

        def endpoint_url
          template? ? TEMPLATE_ENDPOINT : EMAIL_ENDPOINT
        end

        def default_headers
          {
            "X-Postmark-Server-Token" => @api_key
          }
        end

        def standard_body
          {
            "From" => @options.from,
            "To" => @options.to,
            "ReplyTo" => @options.reply_to,
            "Subject" => @options.subject,
            "TextBody" => @options.text,
            "HtmlBody" => @options.html,
            "MessageStream" => @provider_options.message_stream || "outbound"
          }.compact
        end

        def template_body
          {
            "From" => @options.from,
            "To" => @options.to,
            "Cc" => @options.cc,
            "Bcc" => @options.bcc,
            "ReplyTo" => @options.reply_to,
            "TemplateId" => template_id,
            "TemplateAlias" => template_alias,
            "TemplateModel" => @context_options.except(:template_id, :template_alias).compact,
            "MessageStream" => @provider_options.message_stream || "outbound"
          }.compact
        end

        def template_id
          @context_options[:template_id] || @provider_options.template_id
        end

        def template_alias
          @context_options[:template_alias] || @provider_options.template_alias
        end

        def template?
          !!(@context_options[:template_id] || @context_options[:template_alias] ||
            @provider_options.template_id || @provider_options.template_alias)
        end
      end
    end
  end
end
