# frozen_string_literal: true

require "courrier/email/providers/base"
require "courrier/email/providers/inbox"
require "courrier/email/providers/logger"
require "courrier/email/providers/loops"
require "courrier/email/providers/mailgun"
require "courrier/email/providers/mailjet"
require "courrier/email/providers/mailpace"
require "courrier/email/providers/postmark"
require "courrier/email/providers/resend"
require "courrier/email/providers/sendgrid"
require "courrier/email/providers/sparkpost"
require "courrier/email/providers/userlist"

module Courrier
  class Email
    class Provider
      PROVIDERS = {
        inbox: Courrier::Email::Providers::Inbox,
        logger: Courrier::Email::Providers::Logger,
        loops: Courrier::Email::Providers::Loops,
        mailgun: Courrier::Email::Providers::Mailgun,
        mailjet: Courrier::Email::Providers::Mailjet,
        mailpace: Courrier::Email::Providers::Mailpace,
        postmark: Courrier::Email::Providers::Postmark,
        resend: Courrier::Email::Providers::Resend,
        sendgrid: Courrier::Email::Providers::Sendgrid,
        sparkpost: Courrier::Email::Providers::Sparkpost,
        userlist: Courrier::Email::Providers::Userlist
      }

      def initialize(provider: nil, api_key: nil, options: {}, provider_options: {}, context_options: {})
        @provider = provider
        @api_key = api_key

        @options = options
        @provider_options = provider_options
        @context_options = context_options
      end

      def deliver
        raise Courrier::ConfigurationError, "Unknown provider. Choose one of `#{comma_separated_providers}` or provide your own." if provider_invalid?
        raise Courrier::ConfigurationError, "API key must be configured for #{@provider} provider in production environment" if configuration_missing_in_production?

        provider_class.new(
          api_key: @api_key,
          options: @options,
          provider_options: @provider_options,
          context_options: @context_options
        ).deliver
      end

      private

      def provider_invalid?
        @provider.nil? || @provider.to_s.strip.empty?
      end

      def configuration_missing_in_production?
        production? && api_key_required_providers? && api_key_blank?
      end

      def comma_separated_providers = PROVIDERS.keys.join(", ")

      def provider_class
        return PROVIDERS[@provider.to_sym] if PROVIDERS.key?(@provider.to_sym)

        Object.const_get(@provider)
      end

      def api_key_required_providers?
        !%w[logger inbox].include?(@provider.to_s)
      end

      def api_key_blank?
        @api_key.nil? || @api_key.to_s.strip.empty?
      end

      def production?
        defined?(Rails) && Rails.env.production?
      end
    end
  end
end
