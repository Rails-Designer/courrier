# frozen_string_literal: true

require "cgi"

require "courrier/safe_string"

module Courrier
  class ContextValue
    def initialize(value, escape:)
      @value = value
      @escape = escape
    end

    def to_s
      @escape ? CGI.escapeHTML(@value.to_s) : @value.to_s
    end

    def html_safe
      SafeString.new(@value.to_s)
    end
    alias_method :h, :html_safe

    def method_missing(name, *arguments, &block)
      result = @value.send(name, *arguments, &block)

      result.is_a?(String) ? ContextValue.new(result, escape: @escape) : result
    end

    def respond_to_missing?(name, include_private = false)
      @value.respond_to?(name, include_private) || super
    end
  end
end
