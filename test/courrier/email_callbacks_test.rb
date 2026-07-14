require "test_helper"

class Courrier::EmailCallbacksTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_test_email_class
    reset_configuration
    Courrier::Test.clear!
    Courrier::Email.instance_variable_set(:@before_deliver, nil)
    Courrier::Email.instance_variable_set(:@after_deliver, nil)
    TestEmail.instance_variable_set(:@before_deliver, nil)
    TestEmail.instance_variable_set(:@after_deliver, nil)
  end

  def test_before_deliver_callback_fires_before_delivery
    fired_before = false

    TestEmail.before_deliver { fired_before = true }

    email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")
    email.deliver

    assert fired_before
  end

  def test_after_deliver_callback_fires_after_delivery
    fired_after = false

    TestEmail.after_deliver { fired_after = true }

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    assert fired_after
  end

  def test_before_deliver_callback_receives_email_instance
    received_email = nil

    TestEmail.before_deliver { received_email = it }

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")
      email.deliver
      assert_instance_of TestEmail, received_email
    end
  end

  def test_after_deliver_callback_receives_email_and_result
    received_email = nil
    received_result = nil

    TestEmail.after_deliver do |email, result|
      received_email = email
      received_result = result
    end

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")
      email.deliver
    end

    assert_instance_of TestEmail, received_email
    assert_equal "delivery_result", received_result
  end

  def test_multiple_callbacks_fire_in_registration_order
    order = []

    TestEmail.before_deliver { order << :first }
    TestEmail.before_deliver { order << :second }
    TestEmail.before_deliver { order << :third }

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    assert_equal [:first, :second, :third], order
  end

  def test_before_deliver_returning_false_aborts_delivery
    TestEmail.before_deliver { false }

    provider_called = false
    mock_provider = Object.new
    mock_provider.define_singleton_method(:deliver) { provider_called = true }

    Courrier::Email::Provider.stub :new, mock_provider do
      TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    refute provider_called
  end

  def test_class_deliver_triggers_callbacks
    received_email = nil

    TestEmail.before_deliver { received_email = it }

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      TestEmail.deliver(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")
    end

    assert_instance_of TestEmail, received_email
  end

  def test_inherits_parent_callbacks_when_no_child_callbacks_defined
    parent_callbacks = 0

    TestEmail.before_deliver { parent_callbacks += 1 }

    child_class = Class.new(TestEmail)

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      child_class.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    assert_equal 1, parent_callbacks
  end

  def test_child_callbacks_override_parent_callbacks
    child_callbacks = 0
    parent_callbacks = 0

    TestEmail.before_deliver { parent_callbacks += 1 }

    child_class = Class.new(TestEmail)
    child_class.before_deliver { child_callbacks += 1 }

    mock_provider = create_mock_provider
    Courrier::Email::Provider.stub :new, mock_provider do
      child_class.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    assert_equal 1, child_callbacks
    assert_equal 0, parent_callbacks
  end
end