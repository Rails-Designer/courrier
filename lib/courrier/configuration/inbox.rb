# frozen_string_literal: true

module Courrier
  class Configuration
    class Inbox
      attr_accessor :destination, :auto_open, :template_path

      def initialize
        @destination = default_destination
        @auto_open = false
        @template_path = File.expand_path("../../../courrier/email/providers/inbox/default.html.erb", __FILE__)
      end

      private

      def default_destination
        defined?(Rails) ? Rails.root.join("tmp", "courrier", "emails").to_s : File.join(Dir.tmpdir, "courrier", "emails")
      end
    end
  end
end
