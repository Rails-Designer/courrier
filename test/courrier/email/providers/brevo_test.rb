require "test_helper"

module Courrier::Email::Providers
  class BrevoTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "to@railsdesigner.com, cc@railsdesigner.com",
        reply_to: "support@railsdesigner.com",
        cc: "bcc@railsdesigner.com",
        bcc: "archive@railsdesigner.com"
      )

      @provider = Brevo.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "sender" => {"email" => "devs@railsdesigner.com"},
          "to" => [{"email" => "to@railsdesigner.com"}, {"email" => "cc@railsdesigner.com"}],
          "cc" => [{"email" => "bcc@railsdesigner.com"}],
          "bcc" => [{"email" => "archive@railsdesigner.com"}],
          "replyTo" => {"email" => "support@railsdesigner.com"},
          "subject" => "Test Subject",
          "htmlContent" => "<p>Test HTML Body</p>",
          "textContent" => "Test Body"
        },
        @provider.body
      )
    end

    def test_keeps_a_comma_inside_a_quoted_display_name
      recipient = Courrier::Email::Address.with_name("cc@railsdesigner.com", "Rails, Designer")
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "#{recipient}, cc@railsdesigner.com")

      body = Brevo.new(api_key: "test_key", options: email.options).body

      assert_equal [{"email" => recipient}, {"email" => "cc@railsdesigner.com"}], body["to"]
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

    def test_omits_empty_address_fields
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "to@railsdesigner.com",
        cc: "",
        bcc: "   ",
        reply_to: ","
      )

      body = Brevo.new(api_key: "test_key", options: email.options).body

      refute_includes body.keys, "cc"
      refute_includes body.keys, "bcc"
      refute_includes body.keys, "replyTo"
    end
  end
end
