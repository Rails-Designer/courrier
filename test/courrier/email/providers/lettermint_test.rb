require "test_helper"

module Courrier::Email::Providers
  class LettermintTest < Minitest::Test
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
          "route" => "test_route",
          "from" => "devs@railsdesigner.com",
          "to" => ["first@example.com", "second@example.com"],
          "cc" => ["copy@example.com"],
          "bcc" => ["archive@example.com"],
          "reply_to" => ["support@railsdesigner.com"],
          "subject" => "Test Subject",
          "html" => "<p>Test HTML Body</p>",
          "text" => "Test Body"
        },
        @provider.body
      )
    end

    def test_keeps_a_comma_inside_a_quoted_display_name
      recipient = Courrier::Email::Address.with_name("jane@example.com", "Doe, Jane")
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "#{recipient}, bob@example.com")

      assert_equal [recipient, "bob@example.com"], provider_for(email).body["to"]
    end

    def test_omits_empty_address_fields
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com", cc: "", bcc: "   ", reply_to: ",")

      body = provider_for(email).body

      refute_includes body.keys, "cc"
      refute_includes body.keys, "bcc"
      refute_includes body.keys, "reply_to"
    end

    def test_authenticates_with_api_key
      assert_equal({"x-lettermint-token" => "test_key"}, @provider.send(:default_headers))
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Lettermint.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "lettermint",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end

    private

    def provider_for(email)
      provider_options = Courrier::Configuration::ProviderConfig.new
      provider_options.route = "test_route"

      Lettermint.new(api_key: "test_key", options: email.options, provider_options: provider_options)
    end
  end
end
