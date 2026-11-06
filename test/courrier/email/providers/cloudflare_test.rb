require "test_helper"

module Courrier::Email::Providers
  class CloudflareTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "Rails Designer <devs@railsdesigner.com>",
        to: "first@example.com, Second Person <second@example.com>",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Cloudflare.new(api_key: "test_key", options: email.options, provider_options: Struct.new(:account_id).new("acct"))
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "from" => {"address" => "devs@railsdesigner.com", "name" => "Rails Designer"},
          "to" => [{"address" => "first@example.com"}, {"address" => "second@example.com", "name" => "Second Person"}],
          "reply_to" => "support@railsdesigner.com",
          "cc" => [{"address" => "copy@example.com"}],
          "bcc" => [{"address" => "archive@example.com"}],
          "subject" => "Test Subject",
          "text" => "Test Body",
          "html" => "<p>Test HTML Body</p>"
        },
        @provider.body
      )
    end

    def test_authenticates_with_api_key
      assert_equal({"Authorization" => "Bearer test_key"}, @provider.send(:default_headers))
    end
  end
end
