# frozen_string_literal: true

module Smartbill
  module Sdk
    module Contracts
      # Base class for every SmartBill validation contract.
      #
      # Declares shared type predicates (e.g. {DATE_REGEX}) and provides
      # {validate}, the helper services call to run a struct's attributes
      # through the contract and raise {ValidationError} on failure.
      class Base < Dry::Validation::Contract
        # `YYYY-MM-DD`, matching the SmartBill API date format.
        DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/

        class << self
          # Validate +struct+ (a {Models::Struct}) against this contract,
          # raising {ValidationError} with the aggregated error messages
          # when the contract fails. Returns the struct unchanged on success.
          def validate!(struct)
            result = new.call(struct.to_attributes)
            return struct if result.success?

            messages = result.errors.map do |err|
              path = err.path.is_a?(Array) ? err.path.join(".") : err.path
              "#{path} #{err.text}"
            end
            raise ValidationError, "Validation failed: #{messages.join("; ")}"
          end
        end
      end
    end
  end
end
