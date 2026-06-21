# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Reference to an existing document (series + number).
      #
      # Requests use +seriesName+, but the +GET /estimate/invoices+
      # response returns +series+. Both names are accepted on input;
      # serialization always emits +seriesName+.
      class InvoiceRef < Struct
        # Map the API's bare "series" response key onto +series_name+
        # in addition to the inherited snake_case/camelCase transform.
        transform_keys do |key|
          name = INFLECTOR.underscore(key.to_s).to_sym
          name == :series ? :series_name : name
        end

        attribute :series_name, Types::Strict::String
        attribute :number, Types::Strict::String
      end
    end
  end
end
