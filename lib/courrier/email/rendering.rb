# frozen_string_literal: true

require "erb"

require "courrier/context_value"
require "courrier/safe_string"
require "courrier/markdown"

module Courrier
  class Email
    module Rendering
      private

      def method_missing(name, *)
        return in_html_context { render_template("html") || markdown_rendered } if name == :html
        return render_template("text") if name == :text

        value = @context_options[name]
        return value if value.is_a?(SafeString)

        value.is_a?(String) ? ContextValue.new(value, escape: @html_context) : value
      end

      def in_html_context
        previous = @html_context
        @html_context = true

        yield
      ensure
        @html_context = previous
      end

      def in_safe_context
        previous = @html_context
        @html_context = false

        yield
      ensure
        @html_context = previous
      end

      def render_template(format)
        template_path = template_file_path(format)

        File.exist?(template_path) ? ERB.new(File.read(template_path)).result(binding) : nil
      end

      def render_markdown_template
        %w[md markdown].each do |ext|
          template_path = template_file_path(ext)

          return ERB.new(File.read(template_path)).result(binding) if File.exist?(template_path)
        end

        nil
      end

      def markdown_rendered
        return unless Courrier::Markdown.available?

        markdown_content = render_markdown_template || (respond_to?(:markdown, true) ? markdown : nil)

        Courrier::Markdown.render(markdown_content) if markdown_content
      end

      def template_file_path(format)
        class_path = self.class.name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase

        File.join(Courrier.configuration&.email_path, "#{class_path}.#{format}.erb")
      end

      def html_safe(value = nil, &block)
        return in_safe_context { SafeString.new(block.call.to_s) } if block
        return value.html_safe if value.is_a?(ContextValue)

        SafeString.new(value.to_s)
      end
      alias_method :h, :html_safe

      def respond_to_missing?(name, include_private = false) = true
    end
  end
end
