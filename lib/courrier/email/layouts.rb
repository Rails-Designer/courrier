# frozen_string_literal: true

module Courrier
  class Email
    class Layouts
      def initialize(email)
        @email = email
      end

      def build
        return [] if no_layouts?

        [layouts]
      end

      private

      FORMATS = %w[html text]

      def no_layouts? = @email.class.layouts.nil?

      def layouts
        FORMATS.map(&:to_sym).to_h do |format|
          template = @email.class.layouts[format]

          next if template.nil?

          [format, render(template)]
        end
      end

      def render(template)
        return @email.send(template) if template.is_a?(Symbol)
        return template.call if template.is_a?(Class)

        template
      end
    end
  end
end
