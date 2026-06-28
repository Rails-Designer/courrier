# Courrier

API-powered email delivery and newsletter subscription management for Ruby apps

![A cute cartoon mascot wearing a blue postal uniform with red scarf and cap, carrying a leather messenger bag, representing an API-powered email delivery gem for Ruby apps](https://raw.githubusercontent.com/Rails-Designer/courrier/HEAD/.github/cover.jpg)

```ruby
# Quick example
class OrderEmail < Courrier::Email
  def subject = "Here is your order!"

  def text = "Thanks for ordering"

  def html = "<p>Thanks for ordering</p>"
end

OrderEmail.deliver to: "recipient@railsdesigner.com"

# Manage newsletter subscribers
Courrier::Subscriber.create "subscriber@example.com"
Courrier::Subscriber.destroy "subscriber@example.com"
```

<a href="https://railsdesigner.com/" target="_blank">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Rails-Designer/courrier/HEAD/.github/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/Rails-Designer/courrier/HEAD/.github/logo-light.svg">
    <img alt="Rails Designer logo" src="https://raw.githubusercontent.com/Rails-Designer/courrier/HEAD/.github/logo-light.svg" width="240" style="max-width: 100%;">
  </picture>
</a>

**Sponsored By [Rails Designer](https://railsdesigner.com/)**


## Installation

Add the gem:
```bash
bundle add courrier
```
> [!tip]
> For **Rails** apps, use [`rails_courrier`](https://github.com/Rails-Designer/rails_courrier) instead. It includes generators, ActiveJob support (`deliver_later`), inbox previews and more.

Configure Courrier in your app:
```ruby
Courrier.configure do |config|
  config.email = {
    provider: "postmark",
    api_key: "your-api-key"
  }

  config.from = "devs@example.com"
end
```


## Usage

```ruby
class OrderEmail < Courrier::Email
  def subject = "Here is your order!"

  def text
    <<~TEXT
      text body here
    TEXT
  end

  def html
    <<~HTML
      html body here
    HTML
  end
end

# OrderEmail.deliver to: "recipient@railsdesigner.com"
```


## Configuration

Courrier uses a configuration system with three levels (from lowest to highest priority):

1. **Global configuration**
```ruby
Courrier.configure do |config|
  config.email = {
    provider: "postmark",
    api_key: "xyz"
  }

  config.from = "devs@railsdesigner.com"
  config.default_url_options = { host: "railsdesigner.com" }

  # Provider-specific configuration
  config.providers.cloudflare.account_id = "your-account-id"
  config.providers.loops.transactional_id = "default-template"
  config.providers.mailgun.domain = "notifications.railsdesigner.com"

  config.providers.ses.region = "us-east-1"
  config.providers.ses.access_key_id = "your-access-key-id"
  config.providers.ses.secret_access_key = "your-secret-access-key"
end
```

2. **Email class defaults**
```ruby
class OrderEmail < Courrier::Email
  configure from: "orders@railsdesigner.com",
            cc: "records@railsdesigner.com",
            provider: "mailgun"
end
```

3. **Instance options**
```ruby
OrderEmail.deliver to: "recipient@railsdesigner.com",\
                   from: "shop@railsdesigner.com",\
                   provider: "sendgrid",\
                   api_key: "sk_a1b1c3"
```


Provider and API key settings can be overridden using environment variables (`COURRIER_PROVIDER` and `COURRIER_API_KEY`) for both global configuration and email class defaults.


## Custom headers

Email classes can define custom HTTP headers that are sent with every email:
```ruby
class OrderEmail < Courrier::Email
  headers list_unsubscribe_post: "List-Unsubscribe=One-Click"

  def subject = "Rails Icons now supports SVG sprites!"

  def text = # …

  def html = # …
end
```

Useful for adding provider-specific headers like List-Unsubscribe for Postmark, X-Mailer identifiers or custom metadata headers required.


## Custom attributes

Besides the standard email attributes (`from`, `to`, `reply_to`, etc.), you can pass any additional attributes that will be available in your email templates:
```ruby
OrderEmail.deliver to: "recipient@railsdesigner.com",\
                   download_url: "https://example.com/download?token=abc123"
```

These custom attributes are accessible directly in your email class:
```ruby
def text
  <<~TEXT
    #{download_url}
  TEXT
end
```


## Result object

When sending an email through Courrier, a `Result` object is returned that provides information about the delivery attempt. This object offers a simple interface to check the status and access response data.


### Available methods

| Method | Return Type | Description |
|:-------|:-----------|:------------|
| `success?` | Boolean | Returns `true` if the API request was successful |
| `response` | Net::HTTP::Response | The raw HTTP response from the email provider |
| `data` | Hash | Parsed JSON response body from the provider |
| `error` | Exception | Contains any error that occurred during delivery |


### Example

```ruby
delivery = OrderEmail.deliver to: "recipient@example.com"

if delivery.success?
  puts "Email sent successfully!"
  puts "Provider response: #{delivery.data}"
else
  puts "Failed to send email: #{delivery.error}"
end
```


## Providers

Courrier supports these transactional email providers:

- [AWS SES](https://aws.amazon.com/ses/) — requires `aws-sigv4` gem
- [Cloudflare Email Service](https://developers.cloudflare.com/email-service/)
- [Lettermint](https://lettermint.co)
- [Loops](https://loops.so)
- [Mailgun](https://mailgun.com)
- [MailPace](https://mailpace.com)
- [Postmark](https://postmarkapp.com)
- [Resend](https://resend.com)
- [SendGrid](https://sendgrid.com)
- [SMTP2GO](https://www.smtp2go.com/)
- [SparkPost](https://www.sparkpost.com/)
- [Userlist](https://userlist.com)


## More Features

Additional functionality to help with development and testing:


### Layout support

Wrap your email content using layouts:
```ruby
class OrderEmail < Courrier::Email
 layout text: "%{content}\n\nThanks for your order!",
        html: "<div>\n%{content}\n</div>"
end
```

Using a method:
```ruby
class OrderEmail < Courrier::Email
  layout html: :html_layout

  def html_layout
    <<~HTML
      <div style='font-family: ui-sans-serif, system-ui;'>
        %{content}
      </div>
    HTML
  end
end
```

Using a separate class:
```ruby
class OrderEmail < Courrier::Email
  layout html: OrderLayout
end

class OrderLayout
  self.call
    <<~HTML
      <div style='font-family: ui-sans-serif, system-ui;'>
        %{content}
      </div>
    HTML
  end
end
```


### Template files

Instead of defining `text` and `html` methods, you can create ERB template files:
```ruby
class OrderEmail < Courrier::Email
  def subject = "Your order is ready!"

  # text and html content will be loaded from template files
end
```

Create template files alongside your email class (default path is `courrier/emails`):
- `courrier/emails/order_email.text.erb`
- `courrier/emails/order_email.html.erb`

Templates have access to all context options and instance variables:
```erb
<!-- courrier/emails/order_email.html.erb -->
<h1>Hello <%= name %>!</h1>
<p>Your order #<%= order_id %> is ready for pickup.</p>
```

Method definitions take precedence over template files when both exist. You can mix approaches. For example, define text in a method and use a template for the html:
```ruby
class OrderEmail < Courrier::Email
  def subject = "Your order is ready!"

  def text = "Hello #{name}! Your order ##{order_id} is ready."

  # html will be loaded from courrier/emails/order_email.html.erb
end
```


## Markdown support

Courrier supports rendering markdown content to HTML when a markdown gem is available. Simply bundle any supported markdown gem (`redcarpet`, `kramdown` or `commonmarker`) and it will be used.


### Markdown methods

Define a `markdown` method in your email class:
```ruby
class OrderEmail < Courrier::Email
  def subject = "Your order is ready!"

  def markdown
    <<~MARKDOWN
      # Hello #{name}!

      Your order **##{order_id}** is ready for pickup.

      ## Order Details
      - Item: #{item_name}
      - Price: #{price}
    MARKDOWN
  end
end
```


### Markdown templates

Create markdown template files alongside your email class (default path is `courrier/emails`):
- `courrier/emails/order_email.md.erb`
- `courrier/emails/order_email.markdown.erb`

```erb
<!-- courrier/emails/order_email.md.erb -->
# Hello <%= name %>!

Your order **#<%= order_id %>** is ready for pickup.

## Order Details
- Item: <%= item_name %>
- Price: <%= price %>
```

Method definitions take precedence over template files. You can mix approaches. For example, define `text` in a method and use a markdown template for HTML content.


### Auto-generate text from HTML

Automatically generate plain text versions from your HTML emails:
```ruby
config.auto_generate_text = true  # defaults to false
```


### Email address helper

Compose email addresses with display names:
```ruby
class Signup
  include Courrier::Email::Address

  def send_welcome_email(user)
    recipient = email_with_name(user.email_address, user.name)

    WelcomeEmail.deliver to: recipient
  end
end
```


### Logger provider

Use Ruby's built-in Logger for development and testing:

```ruby
config.provider = "logger"  # outputs emails to STDOUT
config.logger = custom_logger  # optional: defaults to ::Logger.new($stdout)
```


### Testing

Courrier provides `Test` and `TestHelper` for testing email delivery, similar to Action Mailer's testing API.

Access all delivered emails:
```ruby
# Clear deliveries between tests
Courrier::Test.clear!

# Access all deliveries
Courrier::Test.deliveries
```

Each delivery record contains:

- `email_class`; the email class name
- `to`, `from`, `reply_to`, `cc`, `bcc`; email addresses
- `subject`; email subject
- `body` - Hash with `:text` and `:html` keys
- `headers`; custom headers
- `provider`; provider used
- `result`; result object with `success?` method
- `timestamp`; delivery time

Include the helper in your test class for assertions:
```ruby
class OrderTest < Minitest::Test
  include Courrier::TestHelper

  def setup
    Courrier::Test.clear!
  end

  def test_sends_confirmation_email
    order = Order.create! product: "Widget", customer_email: "customer@example.com"

    OrderEmail.deliver to: order.customer_email, order: order

    assert_emails_delivered 1
    assert_email_delivered to: "customer@example.com"
    assert_email_delivered OrderEmail, subject: "Order"
  end

  def test_no_emails_when_order_cancelled
    order = Order.create! product: "Widget", status: :cancelled

    assert_no_emails_delivered
  end
end
```

Available assertions:

- `assert_emails_delivered(count)`; assert the number of emails delivered
- `assert_no_emails_delivered`; assert no emails were delivered
- `assert_email_delivered(email_class, to:, from:, subject:, provider:)`; assert an email matching criteria was delivered


### Delivery callbacks

Hook into the email delivery lifecycle with `before_deliver` and `after_deliver` callbacks:
```ruby
class OrderEmail < Courrier::Email
  before_deliver do |email|
    puts "Sending to #{email.options.to}"  # access email options, abort delivery by returning false
  end

  after_deliver do |email, result|
    puts "Delivered: #{result.success?}"  # access email and delivery result
  end
end
```

Callbacks are isolated per class (subclasses don't inherit parent callbacks).


### Preview classes

Preview your emails during development without sending them. Define named scenarios inline on your email class with sample data:
```ruby
class WelcomeEmail < Courrier::Email
  preview :default, to: "test@example.com", name: "John Doe"
  preview :with_code, to: "test@example.com", name: "Jane", code: "WELCOME20"

  preview :random do
    user = User.all.sample
    { to: user.email, name: user.name }
  end

  def subject = "Welcome, #{name}!"
  def html = "<h1>Hello #{name}</h1>"
end
```

Render previews programmatically:

```ruby
result = Courrier::Preview.render("WelcomeEmail", :default)
result.subject  # => "Welcome, John Doe!"
result.html  # => "<h1>Hello John Doe</h1>"
result.text  # => nil (auto-generated if auto_generate_text is enabled)
result.from  # => "sender@example.com" (inherits class/global config)
result.to  # => "test@example.com"
```

Static params via keyword args or dynamic params via a block — both are passed to `Email.new(**params)`. Class-level and global config (like `from`) are inherited automatically.


### Custom providers

Create your own provider by inheriting from `Courrier::Email::Providers::Base`:
```ruby
class CustomProvider < Courrier::Email::Providers::Base
  ENDPOINT_URL = ""

  def body = ""

  def headers = ""
end
```

Then configure it:
```ruby
config.provider = "CustomProvider"
```

Check the [existing providers](https://github.com/Rails-Designer/courrier/tree/main/lib/courrier/email/providers) for implementation examples.




## Newsletter subscriptions

Manage subscribers across popular email marketing platforms:
```ruby
Courrier.configure do |config|
  config.subscriber = {
    provider: "buttondown",
    api_key: "your_api_key"
  }
end
```

```ruby
# Add a subscriber
subscriber = Courrier::Subscriber.create "subscriber@example.com"

# Remove a subscriber
subscriber = Courrier::Subscriber.destroy "subscriber@example.com"

if subscriber.success?
  puts "Subscriber added!"
else
  puts "Error: #{subscriber.error}"
end
```


### Supported providers

- [Beehiiv](https://www.beehiiv.com/) - requires `publication_id`
- [Buttondown](https://buttondown.com)
- [Kit](https://kit.com/) (formerly ConvertKit) - requires `form_id`
- [Loops](https://loops.so/)
- [Mailchimp](https://mailchimp.com/) - requires `dc` and `list_id`
- [MailerLite](https://www.mailerlite.com/)

Provider-specific configuration:
```ruby
config.subscriber = {
  provider: "mailchimp",
  api_key: "your_api_key",
  dc: "us19",
  list_id: "abc123"
}
```


### Custom providers

Create custom providers by inheriting from `Courrier::Subscriber::Base`:
```ruby
class CustomSubscriberProvider < Courrier::Subscriber::Base
  ENDPOINT_URL = "https://api.example.com/subscribers"

  def create(email)
    request(:post, ENDPOINT_URL, {"email" => email})
  end

  def destroy(email)
    request(:delete, "#{ENDPOINT_URL}/#{email}")
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end
end
```

Then configure it:
```ruby
config.subscriber = {
  provider: CustomSubscriberProvider,
  api_key: "your_api_key"
}
```

See [existing providers](https://github.com/Rails-Designer/courrier/tree/main/lib/courrier/subscriber) for more examples.


## FAQ

### Is this for Rails only?
Not at all! Courrier works with any Ruby application. For Rails apps, use [`rails_courrier`](https://github.com/Rails-Designer/rails_courrier).

### Can it send using SMTP?
No. Courrier is specifically built for API-based email delivery.


## Contributing

This project uses [Standard](https://github.com/testdouble/standard) for formatting Ruby code. Please make sure to run `rake` before submitting pull requests.


## License

Courrier is released under the [MIT License](https://opensource.org/licenses/MIT).
