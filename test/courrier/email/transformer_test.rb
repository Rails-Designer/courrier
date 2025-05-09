require "test_helper"

class TransformerTest < Minitest::Test
  def test_removes_unwanted_elements
    html = <<~HTML
      <script>alert('hi')</script>
      <style>body { color: red; }</style>
      <p>Actual content</p>
    HTML

    assert_equal "Actual content", transform(html)
  end

  def test_processes_links
    html = <<~HTML
      <a href="https://railsdesigner.com">Example</a>
      <a href="#anchor">Skip me</a>
    HTML

    assert_equal "Example (https://railsdesigner.com)\nSkip me", transform(html)
  end

  def test_preserves_line_breaks
    html = <<~HTML
      <div>First</div><p>Second</p>
    HTML

    assert_equal "First\nSecond", transform(html)
  end

  def test_preserves_line_breaks_with_proper_html
    html = <<~HTML
      <div>
        First
      </div>

      <p>
        Second
      </p>
    HTML

    assert_equal "First\nSecond", transform(html)
  end

  def test_no_add_extra_line_breaks_between_block_elements
    html = <<~HTML
      <div>First</div><div>Second</div>
    HTML

    assert_equal "First\nSecond", transform(html)
  end

  def test_clean_up
    html = <<~HTML
      <div>  Multiple   spaces  </div>
      <p>  And  newlines  </p>
    HTML

    assert_equal "Multiple spaces\nAnd newlines", transform(html)
  end

  def test_handles_empty_links
    html = <<~HTML
      <a href="https://railsdesigner.com"></a>
      <a href="https://railsdesigner.com">https://railsdesigner.com</a>
    HTML

    assert_equal "https://railsdesigner.com", transform(html)
  end

  private

  def transform(html)
    Courrier::Email::Transformer.new(html).to_text
  end
end
