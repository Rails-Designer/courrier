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
      def initialize(provider: nil, api_key: nil, options: {}, provider_options: {})
        @provider = provider
        @api_key = api_key
        @options = options
        @provider_options = provider_options
      end

      def deliver
        raise Courrier::ConfigurationError, "`provider` and `api_key` must be configured for production environment" if configuration_missing_in_production?
        raise Courrier::ConfigurationError, "Unknown provider. Choose one of `#{comma_separated_providers}` or provide your own." if @provider.empty? || @provider.nil?

        provider_class.new(
          api_key: @api_key,
          options: @options,
          provider_options: @provider_options
        ).deliver
      end

      private

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
      }.freeze

      def configuration_missing_in_production?
        production? && required_attributes_blank?
      end

      def comma_separated_providers = PROVIDERS.keys.join(", ")

      def provider_class
        return PROVIDERS[@provider.to_sym] if PROVIDERS.key?(@provider.to_sym)

        Object.const_get(@provider)
      end

      def required_attributes_blank? = @api_key.empty?

      def production?
        defined?(Rails) && Rails.env.production?
      end
    end
  end
end
