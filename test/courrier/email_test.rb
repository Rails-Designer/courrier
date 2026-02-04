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

  def test_enqueue_sets_queue_options
    TestEmail.enqueue(queue: "emails", wait: 300)

    assert_equal({queue: "emails", wait: 300}, TestEmail.queue_options)
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

  def test_template_rendering_with_files
  email_path = "tmp/test_emails"

  FileUtils.mkdir_p(email_path)
  File.write("#{email_path}/test_email_with_templates.text.erb", "Hello <%= name %>!")
  File.write("#{email_path}/test_email_with_templates.html.erb", "<p>Hello <strong><%= name %></strong>!</p>")

  Courrier.configure do |config|
    config.email_path = email_path
  end

  email = TestEmailWithTemplates.new(
    to: "recipient@railsdesigner.com",
    from: "devs@railsdesigner.com",
    name: "World"
  )

  assert_equal "Hello World!", email.text
  assert_equal "<p>Hello <strong>World</strong>!</p>", email.html

  FileUtils.rm_rf(email_path)
end

def test_method_takes_precedence_over_template
  email_path = "tmp/test_emails"

  FileUtils.mkdir_p(email_path)
  File.write("#{email_path}/test_email_with_mixed_content.text.erb", "Template text")
  File.write("#{email_path}/test_email_with_mixed_content.html.erb", "<p>Template HTML</p>")

  Courrier.configure do |config|
    config.email_path = email_path
  end

  email = TestEmailWithMixedContent.new(
    to: "recipient@railsdesigner.com",
    from: "devs@railsdesigner.com"
  )

  assert_equal "Method text", email.text
  assert_equal "<p>Template HTML</p>", email.html

  FileUtils.rm_rf(email_path)
end

end
