require "test_helper"
require "courrier/subscriber/buttondown"

class Courrier::Subscriber::ButtondownTest < Minitest::Test
  def setup
    @provider = Courrier::Subscriber::Buttondown.new(api_key: "test_key")
  end

  def test_creates_subscriber_with_email_address
    request = capture_http_request { @provider.create("subscriber@example.com") }

    assert_equal "POST", request.method
    assert_equal "/v1/subscribers", request.path
    assert_equal({"email_address" => "subscriber@example.com"}, JSON.parse(request.body))
    assert_equal "2024-08-01", request["X-API-Version"]
    assert_equal "Token test_key", request["Authorization"]
  end

  def test_delete_does_not_override_the_api_version
    request = capture_http_request { @provider.destroy("subscriber@example.com") }

    assert_equal "DELETE", request.method
    assert_nil request["X-API-Version"]
  end

  private

  def capture_http_request
    request = nil
    response = Data.define(:code, :body).new(code: "201", body: "{}")
    http = Object.new
    http.define_singleton_method(:request) do |sent|
      request = sent
      response
    end

    Net::HTTP.stub(:start, ->(*, **, &block) { block.call(http) }) { yield }

    request
  end
end
