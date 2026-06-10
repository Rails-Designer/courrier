# frozen_string_literal: true

module Courrier
  module TestMode
    Delivery = Data.define(:email_class, :to, :from, :reply_to, :cc, :bcc, :subject, :body, :headers, :provider, :result, :timestamp) do
      def success?
        result.success?
      end
    end

    class << self
      def deliveries
        @deliveries ||= []
      end

      def clear!
        @deliveries = []
      end

      def record(email, result)
        deliveries << Delivery.new(
          email_class: email.class.name,
          to: email.options.to,
          from: email.options.from,
          reply_to: email.options.reply_to,
          cc: email.options.cc,
          bcc: email.options.bcc,
          subject: email.options.subject,
          body: {text: email.options.text, html: email.options.html},
          headers: email.class.headers,
          provider: email.provider,
          result: result,
          timestamp: Time.now
        )
      end
    end
  end
end
