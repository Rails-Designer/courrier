require "courrier/email"

class TestEmailWithStringLayouts < Courrier::Email
  layout html: "<div>test</div>", text: "test"
end
