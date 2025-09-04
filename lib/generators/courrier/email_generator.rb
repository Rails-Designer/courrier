module Courrier
  class EmailGenerator < Rails::Generators::NamedBase
    AVAILABLE_TEMPLATES = %w[welcome password_reset]

    desc "Create a new Courrier Email class"

    source_root File.expand_path("templates", __dir__)

    check_class_collision suffix: "Email"

    class_option :skip_suffix, type: :boolean, default: false
    class_option :template, type: :string, desc: "Template type (#{AVAILABLE_TEMPLATES.join(", ")})"

    def copy_mailer_file
      template template_file, destination_path
    end

    private

    def file_name = super.delete_suffix("_email")

    def parent_class = defined?(ApplicationEmail) ? ApplicationEmail : Courrier::Email

    def template_file
      if options[:template] && template_exists?("email/#{options[:template]}.rb.tt")
        "email/#{options[:template]}.rb.tt"
      else
        "email.rb.tt"
      end
    end

    def destination_path
      File.join(Courrier.configuration.email_path, class_path, "#{file_name}#{options[:skip_suffix] ? "" : "_email"}.rb")
    end

    def template_exists?(path)
      find_in_source_paths(path)
    rescue
      nil
    end
  end
end
