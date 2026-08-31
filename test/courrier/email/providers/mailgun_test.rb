require "test_helper"

module Courrier::Email::Providers
  class MailgunTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com"
      )

      @provider = provider_for(email)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "from" => "devs@railsdesigner.com",
          "to" => "first@example.com, second@example.com",
          "h:Reply-To" => "support@railsdesigner.com",
          "subject" => "Test Subject",
          "text" => "Test Body",
          "html" => "<p>Test HTML Body</p>"
        },
        @provider.body
      )
    end

    def test_omits_reply_to_when_not_set
      body = provider_for(TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com")).body

      refute_includes body.keys, "h:Reply-To"
    end

    def test_builds_endpoint_url_from_domain
      assert_equal "https://api.mailgun.net/v3/railsdesigner.com/messages", @provider.send(:endpoint_url)
    end

    def test_requires_a_domain
      provider = Mailgun.new(
        api_key: "test_key",
        options: TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com").options,
        provider_options: Courrier::Configuration::ProviderConfig.new
      )

      error = assert_raises(Courrier::ArgumentError) { provider.send(:endpoint_url) }

      assert_match(/domain/, error.message)
    end

    def test_authenticates_with_api_key
      assert_equal(
        {"Authorization" => "Basic YXBpOnRlc3Rfa2V5"},
        @provider.send(:default_headers)
      )
    end

    def test_submits_as_multipart_form_data
      assert_equal "multipart/form-data", @provider.send(:content_type)
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Mailgun.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "mailgun",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end

    private

    def provider_for(email)
      provider_options = Courrier::Configuration::ProviderConfig.new
      provider_options.domain = "railsdesigner.com"

      Mailgun.new(api_key: "test_key", options: email.options, provider_options: provider_options)
    end
  end
end
