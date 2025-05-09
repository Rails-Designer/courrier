# frozen_string_literal: true

module Courrier
  class Email
    module Address
      class << self
        def with_name(address, name)
          raise Courrier::ArgumentError, "Both `address` and `name` are required" if address.nil? || name.nil?
          raise Courrier::ArgumentError, "Both `address` and `name` must not be empty" if address.empty? || name.empty?

          address = address.gsub(/[<>]/, "")
          formatted_name = format_display_for(name)

          "#{formatted_name} <#{address}>"
        end

        private

        def format_display_for(name)
          return quote_escaped(name) if special_characters_in?(name)

          name
        end

        def quote_escaped(name) = %("#{name.gsub('"', '\\"')}")

        def special_characters_in?(name)
          name =~ /[(),.:;<>@\[\]"]/
        end
      end

      def email_with_name(email, name) = Address.with_name(email, name)
      alias_method :email_address_with_name, :email_with_name
      module_function :email_with_name, :email_address_with_name
    end
  end
end
