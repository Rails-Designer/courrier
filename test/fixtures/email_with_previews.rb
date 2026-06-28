require "courrier/email"

class EmailWithPreviews < Courrier::Email
  preview :default, to: "recipient@example.com", from: "sender@example.com", name: "John"
  preview :with_code, to: "recipient@example.com", from: "sender@example.com", name: "Jane", code: "SECRET"
  preview :no_name, to: "recipient@example.com", from: "sender@example.com"

  preview :dynamic do
    { to: "dynamic@example.com", from: "sender@example.com", name: "Dynamic-#{rand(1000)}" }
  end

  def subject = "Hello, #{name}"

  def html = "<h1>Hello #{name}</h1>"

  def text = "Hello #{name}"
end
