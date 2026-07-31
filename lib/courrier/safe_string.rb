# frozen_string_literal: true

module Courrier
  class SafeString
    def initialize(string) = @string = string.to_s
    def to_s = @string
    def html_safe? = true
  end
end
