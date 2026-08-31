require "courrier/email"

class TestEmailWithHtml < Courrier::Email
  def subject = "Test"

  def html = "<p>Order #{order_id}</p>"
end
