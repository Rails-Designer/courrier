require "courrier/email"

class TestEmailWithSafeAttribute < Courrier::Email
  def subject = "Test"

  def html = "<p>#{html_safe(order_id)}</p>"
end

class TestEmailWithHAttribute < Courrier::Email
  def subject = "Test"

  def html = "<p>#{h(order_id)}</p>"
end

class TestEmailWithSafeBlock < Courrier::Email
  def subject = "Test"

  def html = html_safe { "<p>Order #{order_id}</p>" }
end

class TestEmailWithHBlock < Courrier::Email
  def subject = "Test"

  def html = h { "<p>Order #{order_id}</p>" }
end
