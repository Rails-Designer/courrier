require "courrier/email"

class TestEmailWithHtmlOnlyLayout < Courrier::Email
  layout html: "<html>%{content}</html>"

  def html = "<p>Body</p>"
end

class TestEmailWithTextOnlyLayout < Courrier::Email
  layout text: "%{content}\n\nThanks!"

  def text = "Body"
end
