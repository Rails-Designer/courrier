require "test_helper"

class Courrier::PreviewTest < Minitest::Test
  def setup
    Courrier.configuration = Courrier::Configuration.new
  end

  def test_render_returns_result_with_correct_attributes
    result = Courrier::Preview.render("EmailWithPreviews", :default)

    assert_equal "EmailWithPreviews", result.email_class
    assert_equal "default", result.scenario
    assert_equal "Hello, John", result.subject
    assert_equal "<h1>Hello John</h1>", result.html
    assert_equal "Hello John", result.text
    assert_equal "sender@example.com", result.from
    assert_equal "recipient@example.com", result.to
  end

  def test_render_with_block_params
    result = Courrier::Preview.render("EmailWithPreviews", :dynamic)

    assert_match /Dynamic-\d+/, result.subject
  end

  def test_render_with_code_context_option
    result = Courrier::Preview.render("EmailWithPreviews", :with_code)

    assert_equal "Hello, Jane", result.subject
  end

  def test_render_with_missing_preview_param
    result = Courrier::Preview.render("EmailWithPreviews", :no_name)

    assert_equal "Hello, ", result.subject
  end

  def test_render_raises_for_unknown_class
    assert_raises(NameError) do
      Courrier::Preview.render("NonExistentEmail", :default)
    end
  end

  def test_render_raises_for_unknown_scenario
    assert_raises(KeyError) do
      Courrier::Preview.render("EmailWithPreviews", :bogus)
    end
  end

  def test_result_is_frozen
    result = Courrier::Preview.render("EmailWithPreviews", :default)

    assert result.frozen?
  end

  def test_class_preview_render_with_symbol
    result = EmailWithPreviews.preview(:default)

    assert_equal "Hello, John", result.subject
  end

  def test_class_preview_render_with_string
    result = EmailWithPreviews.preview("default")

    assert_equal "Hello, John", result.subject
  end

  def test_class_preview_render_unknown_scenario
    assert_raises(KeyError) do
      EmailWithPreviews.preview(:bogus)
    end
  end
end
