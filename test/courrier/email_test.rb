require "test_helper"

class Courrier::EmailTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_test_email_class
    reset_configuration
  end

  def test_initialization_with_options
    email = TestEmail.new(
      provider: "test_provider",
      api_key: "test_key",
      to: "recipient@railsdesigner.com",
      from: "devs@railsdesigner.com",
      reply_to: "reply@railsdesigner.com",
      cc: "cc@railsdesigner.com",
      bcc: "bcc@railsdesigner.com"
    )

    assert_equal "test_provider", email.provider
    assert_equal "test_key", email.api_key
    assert_equal "recipient@railsdesigner.com", email.options.to
    assert_equal "devs@railsdesigner.com", email.options.from
    assert_equal "reply@railsdesigner.com", email.options.reply_to
    assert_equal "cc@railsdesigner.com", email.options.cc
    assert_equal "bcc@railsdesigner.com", email.options.bcc
  end

  def test_abstract_methods_raise_error
    email = Courrier::Email.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_nil email.subject

    assert_nil email.text

    assert_nil email.html
  end

  def test_deliver_alias_for_deliver_now
    email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_equal email.method(:deliver_now), email.method(:deliver)
    assert_equal TestEmail.method(:deliver_now), TestEmail.method(:deliver)
  end

  def test_access_context_options_in_email_content
    email = TestEmailWithContext.new(
      to: "recipient@railsdesigner.com",
      from: "devs@railsdesigner.com",
      order_id: "123",
      token: "abc456"
    )

    assert_equal "Order 123", email.subject
    assert_equal "Test order 123 with token abc456", email.text
  end

  def test_missing_context_option_returns_nil
    email = TestEmailWithContext.new(
      to: "recipient@railsdesigner.com",
      from: "devs@railsdesigner.com"
    )

    assert_nil email.order_id
    assert_equal "Order ", email.subject
  end

  def test_url_generation_with_configured_host
    Courrier.configure do |config|
      config.default_url_options = { host: "railsdesigner.com" }
    end

    email = TestEmailWithUrl.new(
      to: "recipient@railsdesigner.com",
      from: "devs@railsdesigner.com"
    )

    assert_equal "Click here: railsdesigner.com", email.text
  end

  def test_url_generation_with_missing_host
    Courrier.configure do |config|
      config.default_url_options = { host: "" }
    end

    email = TestEmailWithUrl.new(
      to: "recipient@railsdesigner.com",
      from: "devs@railsdesigner.com"
    )

    assert_equal "Click here: ", email.text
  end
end
