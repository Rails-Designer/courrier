# frozen_string_literal: true

module Courrier
  module TestHelper
    def assert_emails_delivered(count)
      actual = TestMode.deliveries.size

      assert_equal count, actual, "Expected #{count} email(s) to be delivered, but #{actual} were delivered"
    end

    def assert_no_emails_delivered
      assert_emails_delivered(0)
    end

    def assert_email_delivered(email_class = nil, to: nil, from: nil, subject: nil, provider: nil)
      deliveries = TestMode.deliveries

      matching = deliveries.find do |delivery|
        match_email_class(email_class, delivery.email_class) &&
          match_recipient(to, delivery.to) &&
          match_recipient(from, delivery.from) &&
          match_subject(subject, delivery.subject) &&
          match_provider(provider, delivery.provider)
      end

      assert matching, assertion_message(email_class, to: to, from: from, subject: subject, provider: provider, deliveries: deliveries)
    end

    private

    def match_email_class(expected, actual)
      return true if expected.nil?

      expected == actual || (expected.is_a?(Class) && actual == expected.name)
    end

    def match_recipient(expected, actual)
      return true if expected.nil?

      actual.to_s.include?(expected.to_s)
    end

    def match_subject(expected, actual)
      return true if expected.nil?

      actual.to_s.include?(expected.to_s)
    end

    def match_provider(expected, actual)
      return true if expected.nil?

      actual.to_s == expected.to_s
    end

    def assertion_message(email_class, to:, from:, subject:, provider:, deliveries:)
      "Expected email matching #{[].tap do |criteria|
        criteria << "email_class=#{email_class}" if email_class
        criteria << "to=#{to}" if to
        criteria << "from=#{from}" if from
        criteria << "subject=#{subject}" if subject
        criteria << "provider=#{provider}" if provider
      end.join(", ")} but none found. #{deliveries.size} email(s) delivered."
    end
  end
end
