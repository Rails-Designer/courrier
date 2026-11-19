require "test_helper"

module Courrier::Email::Providers
  class ResendTest < Minitest::Test
    def test_splits_address_lists_into_arrays
      email = TestEmail.new(
        from: "Rails Designer <devs@railsdesigner.com>",
        to: "first@example.com, Second Person <second@example.com>",
        reply_to: "support@railsdesigner.com",
        cc: "Copy Person <copy@example.com>",
        bcc: "archive@example.com, \"Doe, Jane\" <jane@example.com>"
      )

      body = Resend.new(api_key: "test_key", options: email.options).body

      assert_equal "Rails Designer <devs@railsdesigner.com>", body["from"]
      assert_equal ["first@example.com", "Second Person <second@example.com>"], body["to"]
      assert_equal ["support@railsdesigner.com"], body["reply_to"]
      assert_equal ["Copy Person <copy@example.com>"], body["cc"]
      assert_equal ["archive@example.com", "\"Doe, Jane\" <jane@example.com>"], body["bcc"]
    end

    def test_omits_blank_lists
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "first@example.com")

      body = Resend.new(api_key: "test_key", options: email.options).body

      assert_equal ["first@example.com"], body["to"]
      refute body.key?("cc")
      refute body.key?("bcc")
    end
  end
end
