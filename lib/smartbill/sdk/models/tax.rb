# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A VAT rate entry from +GET /tax+.
      class Tax < Struct
        attribute :name, Types::Strict::String.optional.default(nil)
        attribute :percentage, Types::Coercible::Float.optional.default(nil)
        attribute :id, Types::StrOrInt.optional.default(nil)
      end
    end
  end
end
