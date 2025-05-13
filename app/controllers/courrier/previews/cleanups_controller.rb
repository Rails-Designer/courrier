# frozen_string_literal: true

module Courrier
  module Previews
    class CleanupsController < ActionController::Base
      def create
        system("bin/rails courrier:clear")

        redirect_to root_path
      end
    end
  end
end
