# frozen_string_literal: true

module Courrier
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class ArgumentError < ::ArgumentError; end

  class NotImplementedError < ::NotImplementedError; end

  class BackgroundDeliveryError < StandardError; end

  class ActiveJobNotAvailableError < BackgroundDeliveryError; end

  class SerializationError < BackgroundDeliveryError; end

  class QueueError < BackgroundDeliveryError; end
end
