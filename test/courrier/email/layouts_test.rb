require "test_helper"

class Courrier::Email::LayoutsTest < Minitest::Test
  def test_without_layouts
    email = TestEmail.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    assert_equal [], Courrier::Email::Layouts.new(email).build
  end

  def test_string_layouts
    email = TestEmailWithStringLayouts.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    expected = [{ html: "<div>test</div>", text: "test" }]

    assert_equal expected, Courrier::Email::Layouts.new(email).build
  end

  def test_mixed_layouts
    email = TestEmailWithLayouts.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    expected = [{ html: "<p>Test HTML Body</p>", text: "Test Text Body" }]

    assert_equal expected, Courrier::Email::Layouts.new(email).build
  end

  def test_html_only_layout
    email = TestEmailWithHtmlOnlyLayout.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    assert_equal [{ html: "<html>%{content}</html>" }], Courrier::Email::Layouts.new(email).build
    assert_equal "<html><p>Body</p></html>", email.options.html
  end

  def test_text_only_layout
    email = TestEmailWithTextOnlyLayout.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )

    assert_equal [{ text: "%{content}\n\nThanks!" }], Courrier::Email::Layouts.new(email).build
    assert_equal "Body\n\nThanks!", email.options.text
  end
end
