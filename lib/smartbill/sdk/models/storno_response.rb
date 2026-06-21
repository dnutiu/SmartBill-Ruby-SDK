# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +POST /invoice/reverse+.
      class StornoResponse < BaseResponse
        attribute :document_url, Types::Strict::String.optional.default(nil)
        attribute :document_id, Types::StrOrInt.optional.default(nil)
        attribute :document_view_url, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
