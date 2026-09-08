require "test_helper"

class Courrier::Email::Providers::BaseTest < Minitest::Test
  def setup
    @provider = Courrier::Email::Providers::TestProvider.new
  end

  def test_initialize_sets_options
    provider = Courrier::Email::Providers::Base.new(
      api_key: "test_key",
      options: { from: "devs@railsdesigner.com" },
      provider_options: { custom: "value" }
    )

    assert_equal "test_key", provider.instance_variable_get(:@api_key)
    assert_equal({ from: "devs@railsdesigner.com" }, provider.instance_variable_get(:@options))
    assert_equal({ custom: "value" }, provider.instance_variable_get(:@provider_options))
  end

  def test_body_raises_not_implemented_error
    provider = Courrier::Email::Providers::Base.new

    assert_raises NotImplementedError do
      provider.body
    end
  end

  def test_deliver_returns_result
    response_mock = Object.new

    Net::HTTP.stub :start, response_mock do
      result = @provider.deliver

      assert_instance_of Courrier::Email::Result, result
    end
  end

  def test_deliver_handles_errors
    error = StandardError.new("Test error")

    Net::HTTP.stub :start, -> (*) { raise error } do
      result = @provider.deliver

      assert_instance_of Courrier::Email::Result, result
    end
  end

  def test_headers_merges_custom_headers_with_default_headers
    provider = Courrier::Email::Providers::TestProvider.new(
      api_key: "test_key",
      options: {},
      custom_headers: {"foo_bar" => "baz", "Authorization" => "override"}
    )

    headers = provider.send(:headers)

    assert_equal "baz", headers["foo_bar"]
    assert_equal "override", headers["Authorization"]
  end

  def test_headers_returns_only_default_headers_when_no_custom_headers
    provider = Courrier::Email::Providers::TestProvider.new(
      api_key: "test_key",
      options: {}
    )

    headers = provider.send(:headers)

    assert_equal({}, headers)
  end

  def test_address_list_splits_a_plain_comma_separated_list
    assert_equal(
      [{"email" => "first@example.com"}, {"email" => "second@example.com"}],
      @provider.send(:address_list, "first@example.com, second@example.com")
    )
  end

  def test_address_list_keeps_a_comma_inside_a_quoted_display_name
    recipient = Courrier::Email::Address.with_name("jane@example.com", "Doe, Jane")

    assert_equal [{"email" => recipient}], @provider.send(:address_list, recipient)
    assert_equal(
      [{"email" => recipient}, {"email" => "bob@example.com"}],
      @provider.send(:address_list, "#{recipient}, bob@example.com")
    )
  end

  def test_address_list_tolerates_an_escaped_quote_in_the_display_name
    recipient = Courrier::Email::Address.with_name("j@example.com", 'John "JD" Doe')

    assert_equal [recipient], @provider.send(:address_list, recipient, as: :plain)
  end

  def test_address_list_returns_nil_for_blank_input
    assert_nil @provider.send(:address_list, nil)
    assert_nil @provider.send(:address_list, "")
    assert_nil @provider.send(:address_list, "   ")
    assert_nil @provider.send(:address_list, ",")
  end

  def test_address_line_joins_without_breaking_a_quoted_name
    recipient = Courrier::Email::Address.with_name("jane@example.com", "Doe, Jane")
    line = "#{recipient}, bob@example.com"

    assert_equal line, @provider.send(:address_line, line)
  end
end
