# frozen_string_literal: true

require_relative "lib/courrier/version"

Gem::Specification.new do |spec|
  spec.name = "courrier"
  spec.version = Courrier::VERSION
  spec.authors = ["Rails Designer"]
  spec.email = ["devs@railsdesigner.com"]

  spec.summary = "API-powered email delivery for Ruby apps"
  spec.description = "API-powered email delivery for Ruby apps with support for Postmark, SendGrid, Mailgun and more."
  spec.homepage = "https://railsdesigner.com/courrier/"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rails-Designer/courrier/"

  spec.files = Dir["{bin,app,config,lib}/**/*", "Rakefile", "README.md", "courrier.gemspec", "Gemfile", "Gemfile.lock"]

  spec.required_ruby_version = ">= 3.2.0"

  spec.add_dependency "launchy", ">= 3.1", "< 4"
  spec.add_dependency "nokogiri", ">= 1.18", "< 2"
end
