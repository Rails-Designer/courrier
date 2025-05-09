module Courrier
  class Railtie < Rails::Railtie
    config.after_initialize do
      Courrier::Email.default_url_options = Courrier.configuration.default_url_options
    end

    ActiveSupport.on_load(:action_view) do
      include Courrier::Email::Address
    end

    ActiveSupport.on_load(:action_controller) do
      include Courrier::Email::Address
    end

    ActiveSupport.on_load(:active_job) do
      include Courrier::Email::Address
    end

    rake_tasks do
      load File.expand_path("../tasks/courrier.rake", __FILE__)
    end
  end
end
