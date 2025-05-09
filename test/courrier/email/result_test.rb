require "test_helper"

class Courrier::Email::ResultTest < Minitest::Test
  def test_initialize_with_success_response
    response = Data.define(:code, :body).new(
      code: "200",
      body: '{"success": true, "message_id": "test-123"}'
    )
    result = Courrier::Email::Result.new(response: response)

    assert result.success?
    assert_equal({"success" => true, "message_id" => "test-123"}, result.data)
  end

  def test_initialize_with_failure_response
    response = Data.define(:code, :body).new(
      code: "400",
      body: '{"success": false, "error": "Bad request"}'
    )
    result = Courrier::Email::Result.new(response: response)

    refute result.success?
    assert_equal({"success" => false, "error" => "Bad request"}, result.data)
  end

  def test_initialize_with_error
    error = StandardError.new("Connection error")
    result = Courrier::Email::Result.new(error: error)

    refute result.success?
    assert_equal({}, result.data)
  end

  def test_success_predicate_method
    result = Courrier::Email::Result.new(
      response: Data.define(:code, :body).new(code: "200", body: "{}")
    )
    assert result.success?

    result = Courrier::Email::Result.new(
      response: Data.define(:code, :body).new(code: "500", body: "{}")
    )
    refute result.success?
  end
end
