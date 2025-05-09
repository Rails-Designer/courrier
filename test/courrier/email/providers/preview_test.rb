require "test_helper"
require "courrier/email/providers/preview"

class Courrier::Email::Providers::PreviewTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_configuration
  end

  def test_extract_name_and_email_from_full_address
    email = TestEmail.new(
      from: "devs@railsdesigner.com",
      to: "Rails Designer Devs <devs@railsdesigner.com>"
    )
    preview = Courrier::Email::Providers::Preview.new(options: email.options)

    assert_equal "Rails Designer Devs", preview.name
    assert_equal "devs@railsdesigner.com", preview.email
  end

  def test_extract_email_only
    email = TestEmail.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )
    preview = Courrier::Email::Providers::Preview.new(options: email.options)

    assert_nil preview.name
    assert_equal "recipient@railsdesigner.com", preview.email
  end

  def test_prepare_content_with_urls
    Courrier.configure do |config|
      config.default_url_options = { host: "https://railsdesigner.com" }
    end

    email = TestEmailWithUrl.new(
      from: "devs@railsdesigner.com",
      to: "recipient@railsdesigner.com"
    )
    preview = Courrier::Email::Providers::Preview.new(options: email.options)

    assert_includes preview.text, '<a href="https://railsdesigner.com">https://railsdesigner.com</a>'
  end
end
