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
            From:      #{@options.from}
            To:        #{@options.to}
            Subject:   #{@options.subject}

            Text:
            #{@options.text || "(empty)"}

            HTML:
            #{@options.html || "(empty)"}
            #{separator}
          EMAIL
        end

        def separator = "-" * 80
      end
    end
  end
end
