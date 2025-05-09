require "courrier/email"

class TestEmailWithContext < Courrier::Email
  def subject
    "Order #{order_id}"
  end

  def text
    "Test order #{order_id} with token #{token}"
  end
end
