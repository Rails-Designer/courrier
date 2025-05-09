# frozen_string_literal: true

module Courrier
  class Configuration
    class Preview
      attr_accessor :destination, :auto_open, :template_path

      def initialize
        @destination = default_destination
        @auto_open = true
        @template_path = File.expand_path("../../../courrier/email/providers/preview/default.html.erb", __FILE__)
      end

      private

      def default_destination
        return Rails.root.join("tmp", "courrier", "emails").to_s if defined?(Rails)

        File.join(Dir.tmpdir, "courrier", "emails")
      end
    end
  end
end
