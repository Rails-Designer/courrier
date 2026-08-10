require "test_helper"

module Courrier::Email::Providers
  class MailjetTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com",
        reply_to: "support@railsdesigner.com"
      )

      @provider = provider_for(email)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "Messages" => [
            {
              "From" => {"Email" => "devs@railsdesigner.com"},
              "To" => [{"Email" => "first@example.com"}],
              "ReplyTo" => {"Email" => "support@railsdesigner.com"},
              "Subject" => "Test Subject",
              "TextPart" => "Test Body",
              "HTMLPart" => "<p>Test HTML Body</p>"
            }
          ]
        },
        @provider.body
      )
    end

    def test_omits_reply_to_when_not_set
      body = provider_for(TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com")).body

      refute_includes body["Messages"].first.keys, "ReplyTo"
    end

    def test_authenticates_with_api_key_and_secret
      assert_equal(
        {"Authorization" => "Basic dGVzdF9rZXk6dGVzdF9zZWNyZXQ="},
        @provider.send(:default_headers)
      )
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Mailjet.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "mailjet",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end

    private

    def provider_for(email)
      provider_options = Courrier::Configuration::ProviderConfig.new
      provider_options.api_secret = "test_secret"

      Mailjet.new(api_key: "test_key", options: email.options, provider_options: provider_options)
    end
  end
end
