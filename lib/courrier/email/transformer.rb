# frozen_string_literal: true

require "nokogiri"

module Courrier
  class Email
    class Transformer
      def initialize(content)
        @content = content
      end

      def to_text
        Nokogiri::HTML(@content)
          .then { remove_unwanted_elements(_1) }
          .then { process_links(_1) }
          .then { preserve_line_breaks(_1) }
          .then { clean_up(_1) }
      end

      private

      BLOCK_ELEMENTS = %w[p div h1 h2 h3 h4 h5 h6 pre blockquote li]

      def remove_unwanted_elements(html) = html.tap { _1.css("script, style").remove }

      def process_links(html)
        html.tap do |document|
          document.css("a")
            .select { valid?(_1) }
            .reject { _1.text.strip.empty? || _1.text.strip == _1["href"] }
            .each { _1.content = "#{_1.text.strip} (#{_1["href"]})" }
        end
      end

      def preserve_line_breaks(html)
        html.tap do |document|
          document.css(BLOCK_ELEMENTS.join(",")).each { _1.after("\n") }
        end
      end

      def clean_up(html) = html.text.strip.gsub(/ *\n */m, "\n").squeeze(" \n")

      def valid?(link) = link["href"] && !link["href"].start_with?("#")
    end
  end
end
