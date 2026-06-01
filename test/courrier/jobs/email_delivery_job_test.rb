require "test_helper"

# `Courrier::Jobs::EmailDeliveryJob` is only required when `Rails` is defined
# (see lib/courrier/email.rb), so load ActiveJob (which the job inherits from)
# and the ActiveSupport core extension that provides `String#constantize` to
# allow the job class to load and run in isolation without all of Rails.
require "active_job"
require "active_support/core_ext/string/inflections"
require "courrier/jobs/email_delivery_job"

class Courrier::Jobs::EmailDeliveryJobTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_configuration
  end

  def test_perform_preserves_context_options_for_template_rendering
    data = {
      email_class: "TestEmailWithContext",
      provider: "logger",
      api_key: nil,
      options: {
        from: "devs@railsdesigner.com",
        to: "recipient@railsdesigner.com"
      },
      provider_options: nil,
      context_options: {order_id: "42", token: "abc"}
    }

    options_captured = nil
    mock_provider = create_mock_provider

    Courrier::Email::Provider.stub :new, ->(options) { options_captured = options; mock_provider } do
      Courrier::Jobs::EmailDeliveryJob.new.perform(data)
    end

    assert_equal "Order 42", options_captured[:options].subject
    assert_equal "Test order 42 with token abc", options_captured[:options].text
  end

  def test_deliver_later_data_is_active_job_serializable
    require "active_job"
    Courrier.configure do |config|
      config.email = {provider: "logger"}
      config.providers.logger.foo = "bar"
    end

    email = TestEmail.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    captured = nil
    stub_perform_later = ->(data) { captured = data }

    Courrier::Jobs::EmailDeliveryJob.stub :perform_later, stub_perform_later do
      email.deliver_later
    end

    # ActiveJob's argument serializer raises SerializationError on any
    # non-primitive value -- this asserts every value in `data` is serializable.
    ActiveJob::Arguments.serialize([captured])
  end

  def test_perform_handles_nil_context_options
    data = {
      email_class: "TestEmail",
      provider: "logger",
      api_key: nil,
      options: {
        from: "devs@railsdesigner.com",
        to: "recipient@railsdesigner.com"
      },
      provider_options: nil,
      context_options: nil
    }

    mock_provider = create_mock_provider

    Courrier::Email::Provider.stub :new, ->(_) { mock_provider } do
      assert_equal "delivery_result", Courrier::Jobs::EmailDeliveryJob.new.perform(data)
    end
  end
end
