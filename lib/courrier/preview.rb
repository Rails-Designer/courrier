# frozen_string_literal: true

module Courrier
  class Preview
    Result = Data.define(:email_class, :scenario, :subject, :html, :text, :from, :to)

    class << self
      def render(email_class_name, scenario)
        klass = Object.const_get(email_class_name)
        scenario_key = scenario.to_sym

        raise KeyError, "Unknown preview scenario: #{scenario}" unless klass.previews.key?(scenario_key)

        params = klass.previews[scenario_key].call
        email = klass.new(**params)

        Result.new(
          email_class: email_class_name,
          scenario: scenario.to_s,
          subject: email.options.subject,
          html: email.options.html,
          text: email.options.text,
          from: email.options.from,
          to: email.options.to
        )
      end
    end
  end
end
