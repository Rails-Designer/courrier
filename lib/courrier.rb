# frozen_string_literal: true

require "courrier/version"
require "courrier/errors"
require "courrier/configuration"
require "courrier/email"
require "courrier/engine" if defined?(Rails)
require "courrier/railtie" if defined?(Rails)

module Courrier
end
