require "test_helper"

module Courrier::Email::Providers
  class MailpaceTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com, second-copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Mailpace.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "from" => "devs@railsdesigner.com",
          "to" => "first@example.com, second@example.com",
          "cc" => "copy@example.com, second-copy@example.com",
          "bcc" => "archive@example.com",
          "replyto" => "support@railsdesigner.com",
          "subject" => "Test Subject",
          "textbody" => "Test Body",
          "htmlbody" => "<p>Test HTML Body</p>"
        },
        @provider.body
      )
    end

    def test_omits_empty_address_fields
      body = Mailpace.new(
        api_key: "test_key",
        options: TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com", cc: "", bcc: "  ").options
      ).body

      refute_includes body.keys, "cc"
      refute_includes body.keys, "bcc"
    end

    def test_authenticates_with_api_key
      assert_equal({"MailPace-Server-Token" => "test_key"}, @provider.send(:default_headers))
    end
  end
end
