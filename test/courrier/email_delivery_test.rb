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

  def test_provider_options_included_in_delivery
    Courrier.configure do |config|
      config.providers.mailgun.domain = "railsdesigner.com"
      config.providers.mailgun.tracking = true
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

    assert_equal "railsdesigner.com", options_captured[:provider_options][:domain]
    assert_equal true, options_captured[:provider_options][:tracking]
  end
end
