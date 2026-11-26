require "test_helper"
require "courrier/subscriber/mailerlite"

class Courrier::Subscriber::MailerliteTest < Minitest::Test
  def setup
    @provider = Courrier::Subscriber::Mailerlite.new(api_key: "test_key")
  end

  def test_destroy_deletes_the_subscriber_by_id
    requests, result = capture_requests(["200", '{"data":{"id":"31986843064993537"}}'], ["204", ""]) do
      @provider.destroy("subscriber@example.com")
    end

    assert_equal(
      [
        [:get, "https://connect.mailerlite.com/api/subscribers/subscriber%40example.com"],
        [:delete, "https://connect.mailerlite.com/api/subscribers/31986843064993537"]
      ],
      requests
    )
    assert result.success?
  end

  def test_destroy_returns_the_failed_lookup_without_deleting
    requests, result = capture_requests(["404", '{"message":"Resource not found."}']) do
      @provider.destroy("missing@example.com")
    end

    assert_equal [:get], requests.map(&:first)
    refute result.success?
  end

  private

  def capture_requests(*responses)
    requests = []
    response_class = Data.define(:code, :body)

    handler = lambda do |method, url, body = nil|
      requests << [method, url]
      code, response_body = responses.shift
      Courrier::Subscriber::Result.new(response: response_class.new(code: code, body: response_body))
    end

    result = @provider.stub(:request, handler) { yield }

    [requests, result]
  end
end
