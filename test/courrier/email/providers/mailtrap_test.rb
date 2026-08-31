require "test_helper"

module Courrier::Email::Providers
  class MailtrapTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Mailtrap.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "from" => {"email" => "devs@railsdesigner.com"},
          "to" => [{"email" => "first@example.com"}, {"email" => "second@example.com"}],
          "cc" => [{"email" => "copy@example.com"}],
          "bcc" => [{"email" => "archive@example.com"}],
          "reply_to" => {"email" => "support@railsdesigner.com"},
          "subject" => "Test Subject",
          "text" => "Test Body",
          "html" => "<p>Test HTML Body</p>"
        },
        @provider.body
      )
    end

    def test_omits_optional_addresses_when_not_set
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com")
      body = Mailtrap.new(api_key: "test_key", options: email.options).body

      refute_includes body.keys, "cc"
      refute_includes body.keys, "bcc"
      refute_includes body.keys, "reply_to"
    end

    def test_authenticates_with_api_key
      assert_equal({"Api-Token" => "test_key"}, @provider.send(:default_headers))
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Mailtrap.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "mailtrap",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end
  end
end
