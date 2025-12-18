# frozen_string_literal: true

require "courrier/configuration/inbox"
require "courrier/configuration/providers"

module Courrier
  class << self
    attr_writer :configuration

    def configure
      self.configuration ||= Configuration.new

      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :email, :subscriber, :logger, :email_path, :layouts, :default_url_options, :auto_generate_text,
      :from, :reply_to, :cc, :bcc

    attr_reader :providers, :inbox

    def initialize
      @email = {provider: "logger"}
      @subscriber = {}

      @logger = ::Logger.new($stdout)
      @email_path = default_email_path

      @layouts = nil
      @default_url_options = {host: ""}
      @auto_generate_text = false

      @from = nil
      @reply_to = nil
      @cc = nil
      @bcc = nil

      @providers = Courrier::Configuration::Providers.new
      @inbox = Courrier::Configuration::Inbox.new
    end

    def provider
      warn "[DEPRECATION] `provider` is deprecated. Use `email = { provider: '…' }` instead. Will be removed in 1.0.0"

      @email[:provider]
    end

    def provider=(value)
      warn "[DEPRECATION] `provider=` is deprecated. Use `email = { provider: '…' }` instead. Will be removed in 1.0.0"

      @email[:provider] = value
    end

    def api_key
      warn "[DEPRECATION] `api_key` is deprecated. Use `email = { api_key: '…' }` instead. Will be removed in 1.0.0"

      @email[:api_key]
    end

    def api_key=(value)
      warn "[DEPRECATION] `api_key=` is deprecated. Use `email = { api_key: '…' }` instead. Will be removed in 1.0.0"

      @email[:api_key] = value
    end

    private

    def default_email_path
      defined?(Rails) ? Rails.root.join("app", "emails").to_s : File.join("courrier", "emails")
    end
  end
end
