# frozen_string_literal: true

require "logger"

module Courrier
  class Email
    module Providers
      class Logger < Base
        def deliver
          logger = Courrier.configuration.logger
          logger.formatter = proc do |_severity, _datetime, _progname, message|
            "#{format_email_using(message)}\n"
          end

          logger.info(@options)
        end

        private

        def format_email_using(options)
          <<~EMAIL
            #{separator}
            Timestamp: #{Time.now.strftime("%Y-%m-%d %H:%M:%S %z")}
            #{meta_fields(from: options)}

            Text:
            #{@options.text || "(empty)"}

            HTML:
            #{@options.html || "(empty)"}
            #{separator}
          EMAIL
        end

        def separator = "-" * 80

        def meta_fields(from:)
          fields = [
            [:from, "From"],
            [:to, "To"],
            [:reply_to, "Reply-To"],
            [:cc, "Cc"],
            [:bcc, "Bcc"],
            [:subject, "Subject"]
          ]

          fields.map do |field, label|
            value = from.send(field)

            next if value.nil? || value.to_s.strip.empty?

            "#{label}:".ljust(11) + value
          rescue NoMatchingPatternError
            nil
          end.compact.join("\n")
        end
      end
    end
  end
end
