# frozen_string_literal: true

module Courrier
  class Subscriber
    class << self
      def create(email)
        provider.create(email)
      end
      alias_method :add, :create

      def destroy(email)
        provider.destroy(email)
      end
      alias_method :delete, :destroy

      private

      def provider
        @provider ||= provider_class.new(
          api_key: Courrier.configuration.subscriber[:api_key]
        )
      end

      def provider_class
        provider_name = Courrier.configuration.subscriber[:provider]

        return provider_name if provider_name.is_a?(Class)
        require "courrier/subscriber/#{provider_name}"

        Object.const_get("Courrier::Subscriber::#{provider_name.capitalize}")
      end
    end
  end
end
