require "test_helper"

module Courrier::Email::Providers
  class BrevoTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Brevo.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "sender" => {"email" => "devs@railsdesigner.com"},
          "to" => [{"email" => "first@example.com"}, {"email" => "second@example.com"}],
          "cc" => [{"email" => "copy@example.com"}],
          "bcc" => [{"email" => "archive@example.com"}],
          "replyTo" => {"email" => "support@railsdesigner.com"},
          "subject" => "Test Subject",
          "htmlContent" => "<p>Test HTML Body</p>",
          "textContent" => "Test Body"
        },
        @provider.body
      )
    end

    def test_authenticates_with_api_key
      assert_equal({"api-key" => "test_key"}, @provider.send(:default_headers))
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Brevo.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "brevo",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end
  end
end
