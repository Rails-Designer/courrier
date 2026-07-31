require "test_helper"

class Courrier::Email::Providers::PostmarkTest < Minitest::Test
  def setup
    @provider = Courrier::Email::Providers::Postmark.new(
      api_key: "test_key",
      options: Courrier::Email::Options.new(
        from: "devs@railsdesigner.com",
        to: "recipient@railsdesigner.com",
        subject: "Hello",
        text: "Hello there",
        html: "<p>Hello there</p>"
      ),
      provider_options: Courrier::Configuration::ProviderConfig.new,
      context_options: {}
    )
  end

  def test_standard_body_uses_email_endpoint
    assert_equal "https://api.postmarkapp.com/email", @provider.send(:endpoint_url)
    assert_equal "Hello", @provider.body["Subject"]
    assert_equal "Hello there", @provider.body["TextBody"]
    assert_nil @provider.body["TemplateId"]
    assert_nil @provider.body["TemplateModel"]
  end

  def test_template_alias_via_context_options_uses_template_endpoint
    @provider.instance_variable_set(:@context_options, {template_alias: "welcome", user_name: "John"})

    assert_equal "https://api.postmarkapp.com/email/withTemplate", @provider.send(:endpoint_url)

    body = @provider.body

    assert_equal "welcome", body["TemplateAlias"]
    assert_equal({user_name: "John"}, body["TemplateModel"])
    assert_nil body["Subject"]
    assert_nil body["TemplateId"]
  end

  def test_template_id_via_provider_options_uses_template_endpoint
    provider_options = Courrier::Configuration::ProviderConfig.new
    provider_options.template_id = 1234

    @provider.instance_variable_set(:@provider_options, provider_options)

    assert_equal "https://api.postmarkapp.com/email/withTemplate", @provider.send(:endpoint_url)

    body = @provider.body

    assert_equal 1234, body["TemplateId"]
    assert_nil body["TemplateAlias"]
  end

  def test_template_model_excludes_template_keys
    @provider.instance_variable_set(:@context_options, {template_alias: "welcome", user_name: "John", order_id: 42})

    assert_equal({user_name: "John", order_id: 42}, @provider.body["TemplateModel"])
  end

  def test_template_model_compacts_nil_values
    @provider.instance_variable_set(:@context_options, {template_alias: "welcome", user_name: nil, order_id: 42})

    assert_equal({order_id: 42}, @provider.body["TemplateModel"])
  end

  def test_context_options_take_precedence_over_provider_options
    provider_options = Courrier::Configuration::ProviderConfig.new
    provider_options.template_alias = "global-alias"

    @provider.instance_variable_set(:@provider_options, provider_options)
    @provider.instance_variable_set(:@context_options, {template_alias: "local-alias"})

    assert_equal "local-alias", @provider.body["TemplateAlias"]
  end
end
