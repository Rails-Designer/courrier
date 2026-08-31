require "test_helper"

module Courrier::Email::Providers
  class PostmarkTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com, second-copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Postmark.new(api_key: "test_key", options: email.options, provider_options: Courrier::Configuration::ProviderConfig.new)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "From" => "devs@railsdesigner.com",
          "To" => "first@example.com, second@example.com",
          "Cc" => "copy@example.com, second-copy@example.com",
          "Bcc" => "archive@example.com",
          "ReplyTo" => "support@railsdesigner.com",
          "Subject" => "Test Subject",
          "TextBody" => "Test Body",
          "HtmlBody" => "<p>Test HTML Body</p>",
          "MessageStream" => "outbound"
        },
        @provider.body
      )
    end

    def test_omits_empty_address_fields
      body = provider_for(TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com", cc: "", bcc: "  ")).body

      refute_includes body.keys, "Cc"
      refute_includes body.keys, "Bcc"
    end

    def test_authenticates_with_api_key
      assert_equal({"X-Postmark-Server-Token" => "test_key"}, @provider.send(:default_headers))
    end

    private

    def provider_for(email)
      Postmark.new(api_key: "test_key", options: email.options, provider_options: Courrier::Configuration::ProviderConfig.new)
    end
  end
end
