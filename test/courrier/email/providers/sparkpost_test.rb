require "test_helper"

module Courrier::Email::Providers
  class SparkpostTest < Minitest::Test
    def setup
      email = TestEmail.new(
        from: "devs@railsdesigner.com",
        to: "first@example.com, second@example.com",
        reply_to: "support@railsdesigner.com",
        cc: "copy@example.com",
        bcc: "archive@example.com"
      )

      @provider = Sparkpost.new(api_key: "test_key", options: email.options)
    end

    def test_formats_transactional_email
      assert_equal(
        {
          "content" => {
            "reply_to" => "support@railsdesigner.com",
            "from" => "devs@railsdesigner.com",
            "subject" => "Test Subject",
            "text" => "Test Body",
            "html" => "<p>Test HTML Body</p>",
            "headers" => {"CC" => "copy@example.com"}
          },
          "recipients" => [
            {"address" => {"email" => "first@example.com", "header_to" => "first@example.com, second@example.com"}},
            {"address" => {"email" => "second@example.com", "header_to" => "first@example.com, second@example.com"}},
            {"address" => {"email" => "copy@example.com", "header_to" => "first@example.com, second@example.com"}},
            {"address" => {"email" => "archive@example.com", "header_to" => "first@example.com, second@example.com"}}
          ]
        },
        @provider.body
      )
    end

    def test_keeps_a_bcc_out_of_the_headers
      headers = @provider.body["content"]["headers"]

      refute_includes headers.to_s, "archive@example.com"
    end

    def test_omits_the_cc_header_when_there_is_no_cc
      body = provider_for(bcc: "archive@example.com").body

      refute_includes body["content"].keys, "headers"
      assert_equal 2, body["recipients"].size
    end

    def test_omits_empty_address_fields
      body = provider_for(cc: "", bcc: "  ").body

      refute_includes body["content"].keys, "headers"
      assert_equal(
        [{"address" => {"email" => "first@example.com", "header_to" => "first@example.com"}}],
        body["recipients"]
      )
    end

    def test_authenticates_with_api_key
      assert_equal({"Authorization" => "test_key"}, @provider.send(:default_headers))
    end

    private

    def provider_for(**options)
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com", **options)

      Sparkpost.new(api_key: "test_key", options: email.options)
    end
  end
end
