require "test_helper"
require "courrier/subscriber/buttondown"
require "courrier/subscriber/mailerlite"
require "courrier/subscriber/beehiiv"

# A "+tag" address (Gmail-style) must survive being placed in a request URL:
# `+` means a space in a query string and is ambiguous in a path, so an
# un-encoded address addresses the wrong subscriber.
class Courrier::Subscriber::UrlEncodingTest < Minitest::Test
  EMAIL = "subscriber+tag@example.com"
  ENCODED = "subscriber%2Btag%40example.com"

  def test_buttondown_encodes_the_email_in_the_delete_path
    request = capture_request(Courrier::Subscriber::Buttondown.new(api_key: "k")) { it.destroy(EMAIL) }

    assert_equal :delete, request[:method]
    assert_equal "https://api.buttondown.email/v1/subscribers/#{ENCODED}", request[:url]
  end

  def test_mailerlite_encodes_the_email_in_the_delete_path
    request = capture_request(Courrier::Subscriber::Mailerlite.new(api_key: "k")) { it.destroy(EMAIL) }

    assert_equal :delete, request[:method]
    assert_equal "https://connect.mailerlite.com/api/subscribers/#{ENCODED}", request[:url]
  end

  def test_beehiiv_encodes_the_email_in_the_lookup_query
    Courrier.configure { |c| c.subscriber = {publication_id: "pub_1"} }

    request = capture_request(Courrier::Subscriber::Beehiiv.new(api_key: "k")) { it.destroy(EMAIL) }

    assert_equal :get, request[:method]
    assert_equal(
      "https://api.beehiiv.com/v2/publications/pub_1/subscriptions?email=#{ENCODED}",
      request[:url]
    )
  end

  private

  def capture_request(provider)
    request = nil
    result = Courrier::Subscriber::Result.new(response: Data.define(:code, :body).new(code: "200", body: "{}"))

    handler = lambda do |method, url, body = nil|
      request = {method: method, url: url, body: body}
      result
    end

    provider.stub(:request, handler) { yield provider }

    request
  end
end
