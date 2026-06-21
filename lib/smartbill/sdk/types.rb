# frozen_string_literal: true

require "dry-types"

module Smartbill
  module Sdk
    # Shared {Dry::Types} module used by the model structs and the
    # validation contracts.
    #
    # `Strict::` types raise on wrong types (no silent coercion); `Coercible::`
    # types coerce strings/numbers (e.g. `"10"` → `10.0`). Optional fields use
    # `.optional.default(nil)`; collections use `Types::Array.of(...)`.
    module Types
      include Dry::Types()

      # A value that may be either a strict String or a strict Integer — the
      # SmartBill API returns some fields (e.g. +id+, +nextNumber+, +code+)
      # as either, depending on the endpoint.
      StrOrInt = Strict::String | Strict::Integer
    end
  end
end
