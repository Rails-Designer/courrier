require "test_helper"

class Courrier::EmailDeliveryTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_test_email_class
    reset_configuration
  end

  def test_deliver_now_calls_provider_deliver
    provider_mock = Minitest::Mock.new
    provider_mock.expect(:deliver, "delivery_result")

    Courrier::Email::Provider.stub :new, provider_mock do
      result = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver_now

      assert_equal "delivery_result", result
    end

    provider_mock.verify
  end

  def test_class_deliver_now_creates_instance_and_delivers
    email_mock = Minitest::Mock.new
    email_mock.expect(:deliver_now, "delivery_result")

    TestEmail.stub :new, email_mock do
      result = TestEmail.deliver_now(to: "recipient@railsdesigner.com")

      assert_equal "delivery_result", result
    end

    email_mock.verify
  end

  def test_mailgun_provider_options
    Courrier.configure do |config|
      config.providers.mailgun.domain = "railsdesigner.com"

      config.providers.postmark.enable_tracking = true
      config.providers.loops.transactional_id = "tr-1234"
    end

    email = TestEmail.new(
      provider: "mailgun",
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    options_captured = nil
    mock_provider = create_mock_provider

    Courrier::Email::Provider.stub :new, ->(options) { options_captured = options; mock_provider } do
      email.deliver_now
    end

    assert_equal "railsdesigner.com", options_captured[:provider_options].domain
    assert_nil options_captured[:provider_options].enable_tracking
    assert_nil options_captured[:provider_options].transactional_id
  end

  def test_postmark_provider_options
    Courrier.configure do |config|
      config.providers.postmark.enable_tracking = true

      config.providers.mailgun.domain = "railsdesigner.com"
      config.providers.loops.transactional_id = "tr-1234"
    end

    email = TestEmail.new(
      provider: "postmark",
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    options_captured = nil
    mock_provider = create_mock_provider

    Courrier::Email::Provider.stub :new, ->(options) { options_captured = options; mock_provider } do
      email.deliver_now
    end

    assert_equal true, options_captured[:provider_options].enable_tracking
    assert_nil options_captured[:provider_options].domain
    assert_nil options_captured[:provider_options].transactional_id
  end

  def test_loops_provider_options
    Courrier.configure do |config|
      config.providers.loops.transactional_id = "tr-1234"

      config.providers.mailgun.domain = "railsdesigner.com"
      config.providers.postmark.enable_tracking = true
    end

    email = TestEmail.new(
      provider: "loops",
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    options_captured = nil
    mock_provider = create_mock_provider

    Courrier::Email::Provider.stub :new, ->(options) { options_captured = options; mock_provider } do
      email.deliver_now
    end

    assert_equal "tr-1234", options_captured[:provider_options].transactional_id
    assert_nil options_captured[:provider_options].domain
    assert_nil options_captured[:provider_options].enable_tracking
  end
end
