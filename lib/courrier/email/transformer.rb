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
          .then { remove_unwanted_elements(it) }
          .then { process_links(it) }
          .then { preserve_line_breaks(it) }
          .then { clean_up(it) }
      end

      private

      BLOCK_ELEMENTS = %w[p div h1 h2 h3 h4 h5 h6 pre blockquote li]

      def remove_unwanted_elements(html) = html.tap { it.css("script, style").remove }

      def process_links(html)
        html.tap do |document|
          document.css("a")
            .select { valid?(it) }
            .reject { it.text.strip.empty? || it.text.strip == it["href"] }
            .each { it.content = "#{it.text.strip} (#{it["href"]})" }
        end
      end

      def preserve_line_breaks(html)
        html.tap do |document|
          document.css(BLOCK_ELEMENTS.join(",")).each { it.after("\n") }
        end
      end

      def clean_up(html) = html.text.strip.gsub(/ *\n */m, "\n").squeeze(" \n")

      def valid?(link) = link["href"] && !link["href"].start_with?("#")
    end
  end
end
