# frozen_string_literal: true

module Courrier
  module Jobs
    class EmailDeliveryJob < ActiveJob::Base
      def perform(data)
        email_class = data[:email_class].constantize

        email_class.new(
          provider: data[:provider],
          api_key: data[:api_key],
          from: data[:options][:from],
          to: data[:options][:to],
          reply_to: data[:options][:reply_to],
          cc: data[:options][:cc],
          bcc: data[:options][:bcc],
          provider_options: data[:provider_options],
          context_options: data[:context_options]
        ).deliver_now
      end
    end
  end
end
