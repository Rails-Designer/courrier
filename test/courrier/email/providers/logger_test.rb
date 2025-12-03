require "test_helper"

module Courrier::Email::Providers
  class LoggerTest < Minitest::Test
    include TestEmailHelpers

    def test_formats_email_for_logging
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "recipient@railsdesigner.com",
        reply_to: "support@railsdesigner.com"
      )
      logger = Logger.new(options: email.options)

      output = capture_logger_output { logger.deliver }

      assert_includes output, "From:      devs@railsdesigner.com"
      assert_includes output, "To:        recipient@railsdesigner.com"
      assert_includes output, "Subject:   Test Subject"
      assert_includes output, "Text:\nTest Body"
      assert_includes output, "HTML:\n<p>Test HTML Body</p>"
    end

    def test_formats_optional_meta_fields_for_logging
      email = TestEmail.new(
        from: "devs@chirpform.com",
        to: "recipient@chirpform.com",
        reply_to: "reply-to@chirpform.com",
        cc: "cc@chirpform.com",
        bcc: "bcc@chirpform.com"
      )
      logger = Logger.new(options: email.options)

      output = capture_logger_output { logger.deliver }

      assert_includes output, "Reply-To:  reply-to@chirpform.com"
      assert_includes output, "Cc:        cc@chirpform.com"
      assert_includes output, "Bcc:       bcc@chirpform.com"
    end

    private

    def capture_logger_output
      output = StringIO.new
      original_logger = Courrier.configuration.logger

      Courrier.configuration.logger = ::Logger.new(output)

      yield

      output.string
    ensure
      Courrier.configuration.logger = original_logger
    end
  end
end
