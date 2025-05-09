# frozen_string_literal: true

module Courrier
  class Configuration
    class Providers
      def initialize
        @providers = {}
      end

      def method_missing(name, *, **)
        @providers[name.to_sym] ||= ProviderConfig.new
      end

      def respond_to_missing?(name, include_private = false) = true

      def [](provider_name)
        @providers[provider_name.to_sym] ||= ProviderConfig.new
      end

      def to_h = @providers.transform_values(&:to_h)
    end

    class ProviderConfig
      def initialize
        @options = {}
      end

      def method_missing(name, value = nil, **)
        option_name = name.to_s.chomp("=").to_sym

        return @options[option_name] = value if name.to_s.end_with?("=")

        @options[name.to_sym]
      end

      def respond_to_missing?(name, include_private = false) = true

      def to_h = @options
    end
  end
end
