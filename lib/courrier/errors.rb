# frozen_string_literal: true

module Courrier
  class Error < StandardError; end

  class ArgumentError < ::ArgumentError; end

  class NotImplementedError < ::NotImplementedError; end

  class ConfigurationError < Error; end
end
