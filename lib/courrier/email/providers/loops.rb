# frozen_string_literal: true

module Courrier
  class Email
    module Providers
      class Loops < Base
        ENDPOINT_URL = "https://app.loops.so/api/v1/transactional"

        def body
          {
            "email" => @options.to,
            "transactionalId" => @provider_options.transactional_id || raise(Courrier::ArgumentError, "Loops requires a `transactionalId`"),
            "dataVariables" => data_variables
          }.compact
        end

        private

        def headers
          {
            "Authorization" => "Bearer #{@api_key}"
          }
        end

        def data_variables = @context_options.compact
      end
    end
  end
end
