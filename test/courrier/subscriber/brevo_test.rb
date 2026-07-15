require "test_helper"
require "courrier/subscriber/brevo"

class Courrier::Subscriber::BrevoTest < Minitest::Test
  def setup
    Courrier.configure do |config|
      config.subscriber = {
        provider: :brevo,
        api_key: "test_key",
        list_ids: [12, 34]
      }
    end

    @provider = Courrier::Subscriber::Brevo.new(api_key: "test_key")
  end

  def test_creates_contact_in_configured_lists
    request = capture_request do
      @provider.create("subscriber@example.com")
    end

    assert_equal :post, request[:method]
    assert_equal "https://api.brevo.com/v3/contacts", request[:url]
    assert_equal(
      {
        "email" => "subscriber@example.com",
        "listIds" => [12, 34],
        "updateEnabled" => true
      },
      request[:body]
    )
  end

  def test_deletes_contact_by_email
    request = capture_request do
      @provider.destroy("subscriber+tag@example.com")
    end

    assert_equal :delete, request[:method]
    assert_equal "https://api.brevo.com/v3/contacts/subscriber%2Btag%40example.com", request[:url]
    assert_nil request[:body]
  end

  def test_authenticates_with_api_key
    assert_equal(
      {
        "api-key" => "test_key",
        "Content-Type" => "application/json"
      },
      @provider.send(:headers)
    )
  end

  private

  def capture_request
    request = nil
    result = Courrier::Subscriber::Result.new(response: Data.define(:code, :body).new(code: "200", body: "{}"))

    request_handler = lambda do |method, url, body = nil|
      request = {method: method, url: url, body: body}
      result
    end

    @provider.stub :request, request_handler do
      yield
    end

    request
  end
end
