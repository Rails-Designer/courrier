class EmailWithMarkdown < Courrier::Email
  def subject = "Markdown Test"

  def markdown
    <<~MARKDOWN
      # Hello #{name}!

      Order **#{order_id || "123"}** is ready.
    MARKDOWN
  end
end

class EmailWithMarkdownTemplate < Courrier::Email
  def subject = "Markdown Template Test"
end

class EmailWithHtmlAndMarkdown < Courrier::Email
  def subject = "HTML vs Markdown Test"

  def html = "<p>HTML method</p>"

  def markdown
    <<~MARKDOWN
      # This should not be used
    MARKDOWN
  end
end
