# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "launchy"

module Courrier
  class Email
    module Providers
      class Preview < Base
        def deliver
          FileUtils.mkdir_p(config.destination)

          file_path = File.join(config.destination, "#{Time.now.to_i}.html")

          File.write(file_path, ERB.new(File.read(config.template_path)).result(binding))

          Launchy.open(file_path)

          "Preview email saved to #{file_path}#{config.auto_open ? " and opened in browser" : ""}"
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
          content.to_s.gsub(URI::DEFAULT_PARSER.make_regexp(%w[http https])) do |url|
            %(<a href="#{url}">#{url}</a>)
          end
        end

        def config = @config ||= Courrier.configuration.preview
      end
    end
  end
end
