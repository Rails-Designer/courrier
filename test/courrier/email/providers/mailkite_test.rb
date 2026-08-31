require "test_helper"

module Courrier::Email::Providers
  class MailkiteTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Mailkite.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "from" => "devs@railsdesigner.com",
          "to" => ["first@example.com", "second@example.com"],
          "cc" => ["copy@example.com"],
          "bcc" => ["archive@example.com"],
          "replyTo" => "support@railsdesigner.com",
          "subject" => "Test Subject",
          "text" => "Test Body",
          "html" => "<p>Test HTML Body</p>"
        },
        @provider.body
      )
    end

    def test_omits_optional_recipients_when_absent
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com"
      )

      provider = Mailkite.new(api_key: "test_key", options: email.options)

      assert_equal(
        {
          "from" => "devs@railsdesigner.com",
          "to" => ["first@example.com"],
          "subject" => "Test Subject",
          "text" => "Test Body",
          "html" => "<p>Test HTML Body</p>"
        },
        provider.body
      )
    end

    def test_authenticates_with_bearer_api_key
      assert_equal({"Authorization" => "Bearer test_key"}, @provider.send(:default_headers))
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Mailkite.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "mailkite",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end

    def test_omits_empty_address_fields
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com",
        cc: "",
        bcc: "   "
      )

      body = Mailkite.new(api_key: "test_key", options: email.options).body

      refute_includes body.keys, "cc"
      refute_includes body.keys, "bcc"
    end
  end
end
