require "test_helper"

class Courrier::EmailConfigurationTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_test_email_class
    reset_configuration
  end

  def test_initialization_with_class_defaults
    TestEmail.configure(
      provider: "class_provider",
      api_key: "class_key",
      from: "devs@railsdesigner.com",
      reply_to: "class_reply@railsdesigner.com",
      cc: "class_cc@railsdesigner.com",
      bcc: "class_bcc@railsdesigner.com"
    )

    email = TestEmail.new(to: "recipient@railsdesigner.com")

    assert_equal "class_provider", email.provider
    assert_equal "class_key", email.api_key
    assert_equal "recipient@railsdesigner.com", email.options.to
    assert_equal "devs@railsdesigner.com", email.options.from
    assert_equal "class_reply@railsdesigner.com", email.options.reply_to
    assert_equal "class_cc@railsdesigner.com", email.options.cc
    assert_equal "class_bcc@railsdesigner.com", email.options.bcc
  end

  def test_initialization_with_configuration_defaults
    Courrier.configure do |config|
      config.provider = "config_provider"
      config.api_key = "config_key"
      config.from = "devs@railsdesigner.com"
      config.reply_to = "config_reply@railsdesigner.com"
      config.cc = "config_cc@railsdesigner.com"
      config.bcc = "config_bcc@railsdesigner.com"
    end

    email = TestEmail.new(to: "recipient@railsdesigner.com")

    assert_equal "config_provider", email.provider
    assert_equal "config_key", email.api_key
    assert_equal "recipient@railsdesigner.com", email.options.to
    assert_equal "devs@railsdesigner.com", email.options.from
    assert_equal "config_reply@railsdesigner.com", email.options.reply_to
    assert_equal "config_cc@railsdesigner.com", email.options.cc
    assert_equal "config_bcc@railsdesigner.com", email.options.bcc
  end

  def test_instance_options_without_config
    email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_equal "logger", email.provider
    assert_equal "recipient@railsdesigner.com", email.options.to
    assert_equal "devs@railsdesigner.com", email.options.from
  end

  def test_instance_options_override_class_defaults
    TestEmail.configure(provider: "class_provider")

    email = TestEmail.new(provider: "instance_provider", from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_equal "instance_provider", email.provider
  end

  def test_class_defaults_override_configuration
    Courrier.configure { _1.provider = "config_provider" }

    TestEmail.configure(provider: "class_provider")

    email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_equal "class_provider", email.provider
  end

  def test_class_defaults_set_configuration
    Courrier.configure { _1.provider = "config_provider" }

    TestEmail.set(provider: "class_provider")

    email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_equal "class_provider", email.provider
  end

  def test_configuration_used_when_no_class_defaults
    Courrier.configure { _1.provider = "config_provider" }

    email = TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com")

    assert_equal "config_provider", email.provider
  end

  def test_provider_specific_options_from_configuration
    Courrier.configure do |config|
      config.providers.mailgun.domain = "emails.railsdesigner.com"
      config.providers.mailgun.tracking = true
    end
  end

  def test_preview_default_configuration
    assert_equal File.join(Dir.tmpdir, "courrier", "emails"), Courrier.configuration.preview.destination

    assert Courrier.configuration.preview.auto_open
  end

  def test_preview_configuration_can_be_customized
    Courrier.configure do |config|
      config.preview.destination = "/custom/path"
      config.preview.auto_open = false
    end

    assert_equal "/custom/path", Courrier.configuration.preview.destination

    refute Courrier.configuration.preview.auto_open
  end
end
