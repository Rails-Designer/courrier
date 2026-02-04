require "courrier/email"

class TestEmailWithMixedContent < Courrier::Email
  def subject = "Mixed Content Test"

  def text = "Method text"
  # html is defined in template
end
