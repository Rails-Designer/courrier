module Courrier
  class EmailGenerator < Rails::Generators::NamedBase
    desc "Create a new Courrier Email class"

    source_root File.expand_path("templates", __dir__)

    check_class_collision suffix: "Email"

    class_option :skip_suffix, type: :boolean, default: false

    def copy_mailer_file
      template "email.rb", File.join(Courrier.configuration.email_path, class_path, "#{file_name}#{options[:skip_suffix] ? "" : "_email"}.rb")
    end

    private

    def parent_class = defined?(ApplicationEmail) ? ApplicationEmail : Courrier::Email
  end
end
