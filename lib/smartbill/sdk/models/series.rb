# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A document series entry from +GET /series+.
      class Series < Struct
        attribute :name, Types::Strict::String.optional.default(nil)
        attribute :next_number, Types::StrOrInt.optional.default(nil)
        attribute :type, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
