require "test_helper"

class Courrier::Email::OptionsTest < Minitest::Test
  def test_layout_wraps_the_content_at_the_content_token
    options = build_options(
      html: "<p>Hi</p>",
      text: "Hi",
      layouts: [{html: "<div>%{content}</div>", text: "%{content}\n\nThanks!"}]
    )

    assert_equal "<div><p>Hi</p></div>", options.html
    assert_equal "Hi\n\nThanks!", options.text
  end

  def test_layout_keeps_a_literal_percent_sign
    options = build_options(
      html: "<p>Hi</p>",
      layouts: [{html: "<td style='width:100%'>%{content}</td>"}]
    )

    assert_equal "<td style='width:100%'><p>Hi</p></td>", options.html
  end

  def test_layout_keeps_backslash_sequences_in_the_content
    options = build_options(
      text: 'refund code \1 (\\ and \& too)',
      layouts: [{text: "%{content}\n--"}]
    )

    assert_equal "refund code \\1 (\\ and \\& too)\n--", options.text
  end

  private

  def build_options(**overrides)
    Courrier::Email::Options.new(
      {from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com"}.merge(overrides)
    )
  end
end
