require "courrier/email"

class TestEmailWithLayouts < Courrier::Email
  class HtmlLayout
    def self.call
      "<p>Test HTML Body</p>"
    end
  end

  layout html: HtmlLayout, text: :text_layout

  def text_layout
    "Test Text Body"
  end
end
