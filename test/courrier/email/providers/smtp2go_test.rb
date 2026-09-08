require "test_helper"

module Courrier::Email::Providers
  class Smtp2goTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "to@railsdesigner.com, cc@railsdesigner.com",
        cc: "bcc@railsdesigner.com",
        bcc: "archive@railsdesigner.com"
      )

      @provider = Smtp2go.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "sender" => "devs@railsdesigner.com",
          "to" => ["to@railsdesigner.com", "cc@railsdesigner.com"],
          "cc" => ["bcc@railsdesigner.com"],
          "bcc" => ["archive@railsdesigner.com"],
          "subject" => "Test Subject",
          "html_body" => "<p>Test HTML Body</p>",
          "text_body" => "Test Body"
        },
        @provider.body
      )
    end

    def test_keeps_a_comma_inside_a_quoted_display_name
      recipient = Courrier::Email::Address.with_name("cc@railsdesigner.com", "Rails, Designer")
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "#{recipient}, cc@railsdesigner.com")

      assert_equal [recipient, "cc@railsdesigner.com"], Smtp2go.new(api_key: "test_key", options: email.options).body["to"]
    end

    def test_omits_empty_address_fields
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "to@railsdesigner.com", cc: "", bcc: "   ")

      body = Smtp2go.new(api_key: "test_key", options: email.options).body

      refute_includes body.keys, "cc"
      refute_includes body.keys, "bcc"
    end

    def test_authenticates_with_api_key
      assert_equal({"X-Smtp2go-Api-Key" => "test_key"}, @provider.send(:default_headers))
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Smtp2go.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "smtp2go",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end
  end
end
