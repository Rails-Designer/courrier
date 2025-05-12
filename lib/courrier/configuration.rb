# frozen_string_literal: true

require "courrier/configuration/preview"
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
    attr_accessor :provider, :api_key, :logger, :email_path, :layouts, :default_url_options, :auto_generate_text,
      :from, :reply_to, :cc, :bcc
    attr_reader :providers, :preview

    def initialize
      @provider = "logger"
      @api_key = nil
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
      @preview = Courrier::Configuration::Preview.new
    end

    private

    def default_email_path
      defined?(Rails) ? Rails.root.join("app", "emails").to_s : File.join("courrier", "emails")
    end
  end
end
