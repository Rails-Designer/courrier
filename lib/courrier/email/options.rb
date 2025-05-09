# frozen_string_literal: true

require "courrier/email/transformer"

module Courrier
  class Email
    class Options
      attr_reader :from, :to, :reply_to, :cc, :bcc, :subject

      def initialize(options = {})
        @from = options.fetch(:from, nil)

        @to = options.fetch(:to, nil)
        @reply_to = options.fetch(:reply_to, nil)
        @cc = options.fetch(:cc, nil)
        @bcc = options.fetch(:bcc, nil)

        @subject = options.fetch(:subject, "")
        @text = options.fetch(:text, "")
        @html = options.fetch(:html, "")

        @auto_generate_text = options.fetch(:auto_generate_text, false)

        @layouts = Array(options[:layouts])

        raise Courrier::ArgumentError, "Recipient (`to`) is required" unless @to
        raise Courrier::ArgumentError, "Sender (`from`) is required" unless @from
      end

      def text = wrap(transformed_text, with_layout: :text)

      def html = wrap(@html, with_layout: :html)

      private

      def wrap(content, with_layout:)
        return content if content.nil? || content.empty?

        @layouts.reduce(content) do |wrapped, layout_options|
          layout = layout_options[with_layout]

          next wrapped if !layout

          layout % {content: wrapped}
        end
      end

      def transformed_text
        return Courrier::Email::Transformer.new(@html).to_text if @auto_generate_text

        @text
      end
    end
  end
end
