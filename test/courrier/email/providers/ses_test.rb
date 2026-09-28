require "test_helper"

module Courrier::Email::Providers
  class SesTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "to@railsdesigner.com, cc@railsdesigner.com",
        reply_to: "support@railsdesigner.com",
        cc: "bcc@railsdesigner.com",
        bcc: "archive@railsdesigner.com"
      )

      @provider = Ses.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "FromEmailAddress" => "devs@railsdesigner.com",
          "Destination" => {
            "ToAddresses" => ["to@railsdesigner.com", "cc@railsdesigner.com"],
            "CcAddresses" => ["bcc@railsdesigner.com"],
            "BccAddresses" => ["archive@railsdesigner.com"]
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
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "a@railsdesigner.com, b@railsdesigner.com, c@railsdesigner.com")

      assert_equal ["a@railsdesigner.com", "b@railsdesigner.com", "c@railsdesigner.com"], Ses.new(api_key: "k", options: email.options).body["Destination"]["ToAddresses"]
    end

    def test_keeps_a_comma_inside_a_quoted_display_name
      recipient = Courrier::Email::Address.with_name("cc@railsdesigner.com", "Rails, Designer")
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "#{recipient}, cc@railsdesigner.com")

      assert_equal [recipient, "cc@railsdesigner.com"], Ses.new(api_key: "k", options: email.options).body["Destination"]["ToAddresses"]
    end

    def test_omits_empty_address_fields
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "to@railsdesigner.com", cc: "", bcc: "   ", reply_to: ",")

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
