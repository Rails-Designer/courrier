require "courrier/email"

class TestEmailWithTemplates < Courrier::Email
  def subject = "Template Test"
end
