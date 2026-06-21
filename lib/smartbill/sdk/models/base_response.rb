# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Common envelope: +errorText+/+message+/+number+/+series+/+url+.
      class BaseResponse < Struct
        attribute :error_text, Types::Strict::String.optional.default(nil)
        attribute :message, Types::Strict::String.optional.default(nil)
        attribute :number, Types::Strict::String.optional.default(nil)
        attribute :series, Types::Strict::String.optional.default(nil)
        attribute :url, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
