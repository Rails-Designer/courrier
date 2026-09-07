require "test_helper"

module Courrier::Email::Providers
  class SendgridTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Sendgrid.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "from" => {"email" => "devs@railsdesigner.com"},
          "personalizations" => [
            {
              "to" => [{"email" => "first@example.com"}, {"email" => "second@example.com"}],
              "cc" => [{"email" => "copy@example.com"}],
              "bcc" => [{"email" => "archive@example.com"}]
            }
          ],
          "reply_to" => {"email" => "support@railsdesigner.com"},
          "subject" => "Test Subject",
          "content" => [
            {"type" => "text/plain", "value" => "Test Body"},
            {"type" => "text/html", "value" => "<p>Test HTML Body</p>"}
          ]
        },
        @provider.body
      )
    end

    def test_omits_empty_address_fields
      personalization = provider_for(cc: "", bcc: "  ").body["personalizations"].first

      refute_includes personalization.keys, "cc"
      refute_includes personalization.keys, "bcc"
    end

    def test_authenticates_with_api_key
      assert_equal({"Authorization" => "Bearer test_key"}, @provider.send(:default_headers))
    end

    private

    def provider_for(**options)
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com", **options)

      Sendgrid.new(api_key: "test_key", options: email.options)
    end
  end
end
