require "test_helper"

module Courrier::Email::Providers
  class SesTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Ses.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "FromEmailAddress" => "devs@railsdesigner.com",
          "Destination" => {
            "ToAddresses" => ["first@example.com", "second@example.com"],
            "CcAddresses" => ["copy@example.com"],
            "BccAddresses" => ["archive@example.com"]
          },
          "ReplyToAddresses" => ["support@railsdesigner.com"],
          "Content" => {
            "Simple" => {
              "Subject" => {"Data" => "Test Subject"},
              "Body" => {
                "Text" => {"Data" => "Test Body"},
                "Html" => {"Data" => "<p>Test HTML Body</p>"}
              }
            }
          }
        },
        @provider.body
      )
    end

    def test_splits_a_comma_separated_recipient_string
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "a@example.com, b@example.com, c@example.com")

      assert_equal ["a@example.com", "b@example.com", "c@example.com"], Ses.new(api_key: "k", options: email.options).body["Destination"]["ToAddresses"]
    end

    def test_keeps_a_comma_inside_a_quoted_display_name
      recipient = Courrier::Email::Address.with_name("jane@example.com", "Doe, Jane")
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "#{recipient}, bob@example.com")

      assert_equal [recipient, "bob@example.com"], Ses.new(api_key: "k", options: email.options).body["Destination"]["ToAddresses"]
    end

    def test_omits_empty_address_fields
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com", cc: "", bcc: "   ", reply_to: ",")

      body = Ses.new(api_key: "k", options: email.options).body

      refute_includes body["Destination"].keys, "CcAddresses"
      refute_includes body["Destination"].keys, "BccAddresses"
      refute_includes body.keys, "ReplyToAddresses"
    end

    def test_is_available_through_provider_registry
      mock_provider = Minitest::Mock.new
      mock_provider.expect(:deliver, nil)

      Ses.stub :new, mock_provider do
        Courrier::Email::Provider.new(
          provider: "ses",
          api_key: "test_key",
          options: @provider.instance_variable_get(:@options)
        ).deliver
      end

      mock_provider.verify
    end
  end
end
