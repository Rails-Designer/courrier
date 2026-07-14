# Upgrading to Courrier 1.0.0

Courrier 1.0.0 removes previously deprecated configuration APIs. If you're upgrading from 0.x, review the changes below.

## Removed deprecated `config.provider` and `config.api_key`

These were deprecated in favor of the `email` configuration hash.

**Search your codebase for** `config.provider` and `config.api_key` to find occurrences.

**Before (0.x):**

```ruby
Courrier.configure do |config|
  config.provider = "postmark"
  config.api_key = "xyz"
end
```

**After (1.0.0):**

```ruby
Courrier.configure do |config|
  config.email = {
    provider: "postmark",
    api_key: "xyz"
  }
end
```

## Removed `COURRIER_PROVIDER` and `COURRIER_API_KEY` environment variables

Provider and API key can no longer be set via environment variables.

**Search your codebase for** `COURRIER_PROVIDER` and `COURRIER_API_KEY` to find occurrences.

Use the email configuration hash, email class defaults or instance options instead:

```ruby
# Email class default
class OrderEmail < Courrier::Email
  configure provider: "mailgun"
end

# Instance option
OrderEmail.deliver to: "user@example.com", provider: "sendgrid", api_key: "sk_abc"
```
