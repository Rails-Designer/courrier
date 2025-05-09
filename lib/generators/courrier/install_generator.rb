module Courrier
  class InstallGenerator < Rails::Generators::Base
    desc "Creates the initializer for Courrier"

    source_root File.expand_path("templates", __dir__)

    def copy_initializer_file
      template "initializer.rb", "config/initializers/courrier.rb"
    end
  end
end
