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

Generate the configuration file:
```bash
bin/rails generate courrier:install
```

This creates `config/initializers/courrier.rb` for configuring email providers and default settings.


## Usage

Generate a new email:
```bash
bin/rails generate courrier:email Order
```

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

💡 Write your email content using the [Minimal Email Editor](https://railsdesigner.com/minimal-email-editor/).


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
  config.providers.loops.transactional_id = "default-template"
  config.providers.mailgun.domain = "notifications.railsdesigner.com"
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


## Custom attributes

Besides the standard email attributes (`from`, `to`, `reply_to`, etc.), you can pass any additional attributes that will be available in your email templates:
```ruby
OrderEmail.deliver to: "recipient@railsdesigner.com",\
                   download_url: downloads_path(token: "token")
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
delivery = OrderEmail.deliver(to: "recipient@example.com")

if delivery.success?
  puts "Email sent successfully!"
  puts "Provider response: #{delivery.data}"
else
  puts "Failed to send email: #{delivery.error}"
end
```


## Providers

Courrier supports these transactional email providers:

- [Loops](https://loops.so)
- [Mailgun](https://mailgun.com)
- [MailPace](https://mailpace.com)
- [Postmark](https://postmarkapp.com)
- [Resend](https://resend.com)
- [Userlist](https://userlist.com)


## More Features

Additional functionality to help with development and testing:


### Background jobs (Rails only)

Use `deliver_later` to enqueue delivering using Rails' ActiveJob. You can set
various ActiveJob-supported options in the email class, like so: `enqueue queue: "emails", wait: 5.minutes`.

- `queue`, enqueue the email on the specified queue;
- `wait`, enqueue the email to be delivered with a delay;
- `wait_until`, enqueue the email to be delivered at (after) a specific date/time;
- `priority`, enqueues the email with the specified priority.


### Inbox (Rails only)

You can preview your emails in the inbox:
```ruby
config.provider = "inbox"

# And add to your routes:
mount Courrier::Engine => "/courrier"
```

If you want to automatically open every email in your default browser:
```ruby
config.provider = "inbox"
config.inbox.auto_open = true
```

Emails are automatically cleared with `bin/rails tmp:clear`, or manually with `bin/rails courrier:clear`.


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


### Auto-generate text from HTML

Automatically generate plain text versions from your HTML emails:
```ruby
config.auto_generate_text = true # Defaults to false
```


### Email address helper

Compose email addresses with display names:
```ruby
class SignupsController < ApplicationController
  def create
    recipient = email_with_name("devs@railsdesigner.com", "Rails Designer Devs")

    WelcomeEmail.deliver to: recipient
  end
end
```

In Plain Ruby Objects:
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
config.provider = "logger" # outputs emails to STDOUT
config.logger = custom_logger # optional: defaults to ::Logger.new($stdout)
```


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

### Is this a replacement for ActionMailer?
Yes! While different in approach, Courrier can fully replace ActionMailer. It's a modern alternative that focuses on API-based delivery. The main difference is in how emails are structured - Courrier uses a more straightforward, class-based approach.

### Is this for Rails only?
Not at all! While Courrier has some Rails-specific goodies (like the inbox preview feature and generators), it works great with any Ruby application.

### Can it send using SMTP?
No - Courrier is specifically built for API-based email delivery. If SMTP is needed, ActionMailer would be a better choices.

### Can separate view templates be created (like ActionMailer)?
The approach is different here. Instead of separate view files, email content is defined right in the email class using `text` and `html` methods. Layouts can be used to share common templates. This makes emails more self-contained and easier to reason about.

### What's the main benefit over ActionMailer?
Courrier offers a simpler, more modern approach to sending emails. Each email is a standalone class, configuration is straightforward (typically just only an API key is needed) and it packs few quality-of-life features (like the inbox feature and auto-generate text version).


## Contributing

This project uses [Standard](https://github.com/testdouble/standard) for formatting Ruby code. Please make sure to run `rake` before submitting pull requests.


## License

Courrier is released under the [MIT License](https://opensource.org/licenses/MIT).
