# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "courrier"
require "minitest/autorun"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { require _1 }
Dir[File.expand_path("fixtures/**/*.rb", __dir__)].each { require _1 }
