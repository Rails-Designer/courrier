# frozen_string_literal: true

require "courrier/email/address"
require "courrier/email/layouts"
require "courrier/email/options"
require "courrier/email/provider"

module Courrier
  class Email
    attr_accessor :provider, :api_key, :default_url_options, :options

    class << self
      %w[provider api_key from reply_to cc bcc layouts default_url_options].each do |attribute|
        define_method(attribute) do
          instance_variable_get("@#{attribute}") ||
            (superclass.respond_to?(attribute) ? superclass.send(attribute) : nil) ||
            Courrier.configuration&.send(attribute)
        end

        define_method("#{attribute}=") do |value|
          instance_variable_set("@#{attribute}", value)
        end
      end

      def deliver(options = {})
        new(options).deliver_now
      end
      alias_method :deliver_now, :deliver

      def configure(**options)
        options.each { |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
      end
      alias_method :set, :configure

      def layout(options = {})
        self.layouts = options
      end

      def inherited(subclass)
        super

        # If you read this and know how to move this Rails-specific logic somewhere
        # else, e.g. `lib/courrier/railtie.rb`, open a PR ❤️
        if defined?(Rails) && Rails.application
          subclass.include Rails.application.routes.url_helpers
        end
      end
    end

    def initialize(options = {})
      @provider = options[:provider] || ENV["COURRIER_PROVIDER"] || self.class.provider || Courrier.configuration&.provider
      @api_key = options[:api_key] || ENV["COURRIER_PROVIDER"] || self.class.api_key || Courrier.configuration&.api_key

      @default_url_options = self.class.default_url_options.merge(options[:default_url_options] || {})
      @context_options = options.except(:provider, :api_key, :from, :to, :reply_to, :cc, :bcc, :subject, :text, :html)
      @options = Email::Options.new(
        options.merge(
          from: options[:from] || self.class.from || Courrier.configuration&.from,
          reply_to: options[:reply_to] || self.class.reply_to || Courrier.configuration&.reply_to,
          cc: options[:cc] || self.class.cc || Courrier.configuration&.cc,
          bcc: options[:bcc] || self.class.bcc || Courrier.configuration&.bcc,
          subject: subject,
          text: text,
          html: html,
          auto_generate_text: Courrier.configuration&.auto_generate_text,
          layouts: Courrier::Email::Layouts.new(self).build
        )
      )
    end

    def deliver
      if delivery_disabled?
        Courrier.configuration&.logger&.info "[Courrier] Email delivery skipped: delivery is disabled via environment variable"

        return nil
      end

      Provider.new(
        provider: @provider,
        api_key: @api_key,
        options: @options,
        provider_options: Courrier.configuration&.providers&.[](@provider.to_s.downcase.to_sym)&.to_h
      ).deliver
    end
    alias_method :deliver_now, :deliver

    private

    def delivery_disabled?
      ENV["COURRIER_EMAIL_DISABLED"] == "true" || ENV["COURRIER_EMAIL_ENABLED"] == "false"
    end

    def method_missing(name, *) = @context_options[name]

    def respond_to_missing?(name, include_private = false) = true
  end
end
