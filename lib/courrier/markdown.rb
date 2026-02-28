# frozen_string_literal: true

module Courrier
  class Markdown
    class << self
      def available?
        defined?(::Redcarpet) || defined?(::Kramdown) || defined?(::Commonmarker)
      end

      def render(text)
        return unless available?

        parser.parse(text.to_s)
      end

      private

      def parser
        @parser ||= available_parser.new
      end

      def available_parser
        return RedcarpetParser if defined?(::Redcarpet)
        return KramdownParser if defined?(::Kramdown)
        return CommonmarkerParser if defined?(::Commonmarker)

        Parser
      end
    end

    class Parser
      def parse(text) = text.to_s
    end

    class RedcarpetParser < Parser
      def parse(text)
        renderer = Redcarpet::Render::HTML.new
        markdown = Redcarpet::Markdown.new(renderer)

        markdown.render(text)
      end
    end

    class KramdownParser < Parser
      def parse(text) = Kramdown::Document.new(text).to_html
    end

    class CommonmarkerParser < Parser
      def parse(text) = Commonmarker.to_html(text)
    end
  end
end
