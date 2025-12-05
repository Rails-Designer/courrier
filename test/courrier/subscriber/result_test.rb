require "test_helper"

require "courrier/subscriber/result"

class Courrier::Subscriber::ResultTest < Minitest::Test
  def test_initialize_with_success_response
    response = Data.define(:code, :body).new(
      code: "200",
      body: '{"id": "sub-123", "email": "test@example.com"}'
    )
    result = Courrier::Subscriber::Result.new(response: response)

    assert result.success?
    assert_equal({"id" => "sub-123", "email" => "test@example.com"}, result.data)
  end

  def test_initialize_with_failure_response
    response = Data.define(:code, :body).new(
      code: "400",
      body: '{"error": "Invalid email"}'
    )
    result = Courrier::Subscriber::Result.new(response: response)

    refute result.success?
    assert_equal({"error" => "Invalid email"}, result.data)
  end

  def test_initialize_with_error
    error = StandardError.new("Connection error")
    result = Courrier::Subscriber::Result.new(error: error)

    refute result.success?
    assert_equal({}, result.data)
  end

  def test_success_predicate_method
    result = Courrier::Subscriber::Result.new(
      response: Data.define(:code, :body).new(code: "200", body: "{}")
    )
    assert result.success?

    result = Courrier::Subscriber::Result.new(
      response: Data.define(:code, :body).new(code: "500", body: "{}")
    )
    refute result.success?
  end
end
