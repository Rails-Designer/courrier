require "test_helper"
require "courrier/email/provider"

class TestCourrierEmailProvider < Minitest::Test
  def setup
    Object.send(:remove_const, :Rails) if defined?(Rails)
  end

  def test_raises_error_for_empty_provider
    provider = Courrier::Email::Provider.new(
      provider: "",
      api_key: "test-key"
    )

    error = assert_raises(Courrier::ConfigurationError) do
      provider.deliver
    end

    assert_match "Unknown provider", error.message
  end

  def test_raises_error_in_production_without_config
    stub_rails_production

    provider = Courrier::Email::Provider.new(
      provider: "mailgun",
      api_key: ""
    )

    error = assert_raises(Courrier::ConfigurationError) do
      provider.deliver
    end

    assert_equal "`provider` and `api_key` must be configured for production environment", error.message
  end

  def test_initializes_correct_provider_class
    provider_classes = {
      logger: Courrier::Email::Providers::Logger,
      loops: Courrier::Email::Providers::Loops,
      mailgun: Courrier::Email::Providers::Mailgun,
      mailjet: Courrier::Email::Providers::Mailjet,
      mailpace: Courrier::Email::Providers::Mailpace,
      postmark: Courrier::Email::Providers::Postmark,
      preview: Courrier::Email::Providers::Preview,
      sendgrid: Courrier::Email::Providers::Sendgrid,
      sparkpost: Courrier::Email::Providers::Sparkpost
    }

    provider_classes.each do |provider_name, provider_class|
      provider_instance = Courrier::Email::Provider.new(
        provider: provider_name.to_s,
        api_key: "test-key",
        options: { test: true },
        provider_options: { custom: "value" }
      )

      mock_provider = Minitest::Mock.new

      mock_provider.expect(:deliver, nil)

      provider_class.stub :new, mock_provider do
        provider_instance.deliver
      end

      mock_provider.verify
    end
  end

  def test_passes_correct_arguments_to_provider
    mock_provider = Minitest::Mock.new

    mock_provider.expect(
      :deliver,
      nil
    )

    Courrier::Email::Providers::Mailgun.stub :new, mock_provider do
      provider = Courrier::Email::Provider.new(
        provider: "mailgun",
        api_key: "test-key",
        options: { test: true },
        provider_options: { custom: "value" }
      )

      provider.deliver
    end

    mock_provider.verify
  end

  def test_accepts_custom_provider_class_name
    custom_class = Class.new(Courrier::Email::Providers::Base) do
      def deliver; end
    end

    Object.const_set(:CustomTestProvider, custom_class)

    provider = Courrier::Email::Provider.new(provider: "CustomTestProvider")

    provider.deliver
  ensure
    Object.send(:remove_const, :CustomTestProvider)
  end

  private

  def stub_rails_production
    rails = Module.new
    environment = Minitest::Mock.new

    environment.expect(:production?, true)
    rails.define_singleton_method(:env) { environment }

    Object.const_set(:Rails, rails)
  end
end
