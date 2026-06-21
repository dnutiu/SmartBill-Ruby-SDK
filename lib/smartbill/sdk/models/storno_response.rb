# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +POST /invoice/reverse+.
      class StornoResponse < BaseResponse
        field :document_url
        field :document_id
        field :document_view_url
      end
    end
  end
end
