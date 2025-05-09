require "courrier/email"

class TestEmail < Courrier::Email
  def subject
    "Test Subject"
  end

  def html
    "<p>Test HTML Body</p>"
  end

  def text
    "Test Body"
  end
end
