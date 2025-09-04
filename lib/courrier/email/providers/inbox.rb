# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "launchy"

module Courrier
  class Email
    module Providers
      class Inbox < Base
        def deliver
          FileUtils.mkdir_p(config.destination)

          file_path = File.join(config.destination, "#{Time.now.to_i}.html")

          File.write(file_path, ERB.new(File.read(config.template_path)).result(binding))

          Launchy.open(file_path) if config.auto_open

          "📮 Email saved to #{file_path} and #{email_destination}"
        end

        def name = extract(@options.to)[:name]

        def email = extract(@options.to)[:email]

        def text = prepare(@options.text)

        def html = prepare(@options.html)

        private

        def extract(to)
          if to.to_s =~ /(.*?)\s*<(.+?)>/
            {name: $1.strip, email: $2.strip}
          else
            {name: nil, email: to.to_s.strip}
          end
        end

        def prepare(content)
          content.to_s.gsub(URL_PARSER.make_regexp(%w[http https])) do |url|
            %(<a href="#{url}">#{url}</a>)
          end
        end

        def config = @config ||= Courrier.configuration.inbox

        def email_destination
          return "opened in your default browser" if config.auto_open

          path = begin
            Rails.application.routes.url_helpers.courrier_path
          rescue
            "/courrier/ (Note: Add `mount Courrier::Engine => \"/courrier\"` to your routes.rb to enable proper routing)"
          end

          "available at #{path}"
        end

        URL_PARSER = (
          defined?(URI::RFC2396_PARSER) ? URI::RFC2396_PARSER : URI::DEFAULT_PARSER
        )

        class Email < Data.define(:path, :filename, :metadata)
          Metadata = Data.define(:to, :subject)

          def self.from_file(path)
            content = File.read(path)
            json = content[/<!--\s*(.*?)\s*-->/m, 1]
            metadata = JSON.parse(json, symbolize_names: true)

            new(
              path: path,
              filename: File.basename(path),
              metadata: Metadata.new(**metadata)
            )
          end
        end
      end
    end
  end
end
