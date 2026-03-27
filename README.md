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


Provider and API key settings can be overridden using environment variables (`COURRIER_PROVIDER` and `COURRIER_API_KEY`).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Rails-Designer/courrier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Rails-Designer/courrier/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).