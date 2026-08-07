require "test_helper"

module Courrier::Email::Providers
  class SmtpcomTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = provider_for(email)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "channel" => "test_channel",
          "recipients" => {
            "to" => [{"address" => "first@example.com"}, {"address" => "second@example.com"}],
            "cc" => [{"address" => "copy@example.com"}],
            "bcc" => [{"address" => "archive@example.com"}]
          },
          "originator" => {
            "from" => {"address" => "devs@railsdesigner.com"},
            "reply_to" => {"address" => "support@railsdesigner.com"}
          },
          "subject" => "Test Subject",
          "body" => {
            "parts" => [
              {"type" => "text/plain", "charset" => "UTF-8", "encoding" => "base64", "content" => ["Test Body"].pack("m0")},
              {"type" => "text/html", "charset" => "UTF-8", "encoding" => "base64", "content" => ["<p>Test HTML Body</p>"].pack("m0")}
            ]
          }
        },
        @provider.body
      )
    end

    def test_omits_optional_addresses_when_not_set
      body = provider_for(TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com")).body

      refute_includes body["recipients"].keys, "cc"
      refute_includes body["recipients"].keys, "bcc"
      refute_includes body["originator"].keys, "reply_to"
    end

    def test_requires_a_channel
      provider = Smtpcom.new(
        api_key: "test_key",
        options: TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com").options,
        provider_options: Courrier::Configuration::ProviderConfig.new
      )

      error = assert_raises(Courrier::ArgumentError) { provider.body }

      assert_match(/channel/, error.message)
    end

    def test_authenticates_with_api_key
      assert_equal(
        {"Authorization" => "Basic #{["api:test_key"].pack("m0")}"},
        @provider.send(:default_headers)
      )
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Smtpcom.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "smtpcom",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end

    private

    def provider_for(email)
      provider_options = Courrier::Configuration::ProviderConfig.new
      provider_options.channel = "test_channel"

      Smtpcom.new(api_key: "test_key", options: email.options, provider_options: provider_options)
    end
  end
end
