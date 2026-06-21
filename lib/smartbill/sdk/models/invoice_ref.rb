# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Reference to an existing document (series + number).
      #
      # Requests use +seriesName+, but the +GET /estimate/invoices+
      # response returns +series+. Both names are accepted on input;
      # serialization always emits +seriesName+.
      class InvoiceRef < Model
        field :series_name, required: true, input_keys: ["series"]
        field :number, required: true
      end
    end
  end
end
