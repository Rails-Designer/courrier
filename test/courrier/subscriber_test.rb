require "test_helper"

require "courrier/subscriber"
require "courrier/subscriber/result"

class Courrier::SubscriberTest < Minitest::Test
  def setup
    reset_configuration
  end

  def test_create_with_configured_provider
    Courrier.configure do |config|
      config.subscriber = {
        provider: :buttondown,
        api_key: "test_key"
      }
    end

    provider_mock = Minitest::Mock.new
    provider_mock.expect :create, Courrier::Subscriber::Result.new(response: success_response), ["test@example.com"]

    Courrier::Subscriber.stub :provider, provider_mock do
      result = Courrier::Subscriber.create("test@example.com")
      assert result.success?
    end

    provider_mock.verify
  end

  def test_destroy_with_configured_provider
    Courrier.configure do |config|
      config.subscriber = {
        provider: :buttondown,
        api_key: "test_key"
      }
    end

    provider_mock = Minitest::Mock.new
    provider_mock.expect :destroy, Courrier::Subscriber::Result.new(response: success_response), ["test@example.com"]

    Courrier::Subscriber.stub :provider, provider_mock do
      result = Courrier::Subscriber.destroy("test@example.com")
      assert result.success?
    end

    provider_mock.verify
  end

  def test_add_alias_for_create
    assert_equal Courrier::Subscriber.method(:create), Courrier::Subscriber.method(:add)
  end

  def test_delete_alias_for_destroy
    assert_equal Courrier::Subscriber.method(:destroy), Courrier::Subscriber.method(:delete)
  end

  private

  def success_response
    Data.define(:code, :body).new(code: "200", body: '{"success": true}')
  end

  def reset_configuration
    Courrier.configuration = nil
    Courrier.configure do |config|
      config.subscriber = {
        provider: nil,
        subscriber_api_key: nil
      }
    end
  end
end
