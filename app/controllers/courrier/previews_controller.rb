# frozen_string_literal: true

module Courrier
  class PreviewsController < ActionController::Base
    def index
      @emails = emails.map { Courrier::Email::Providers::Inbox::Email.from_file(_1) }
    end

    def show
      file_path = File.join(Courrier.configuration.inbox.destination, params[:id])
      content = File.read(file_path)

      render html: content.html_safe, layout: false
    end

    private

    def emails
      @emails ||= Dir.glob("#{Courrier.configuration.inbox.destination}/*.html")
        .sort_by { -File.basename(_1, ".html").to_i }
    end
  end
end
