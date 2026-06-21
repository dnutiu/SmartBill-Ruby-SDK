# frozen_string_literal: true

require_relative "base"

module Smartbill
  module Sdk
    module Models
      # A VAT rate entry from +GET /tax+.
      class Tax < Model
        field :name
        field :percentage
        field :id
      end

      # A document series entry from +GET /series+.
      class Series < Model
        field :name
        field :next_number
        field :type
      end

      # Parsed response of +GET /tax+.
      class TaxesResponse < Model
        field :error_text
        field :message
        field :taxes, type: [Tax], default: []
      end

      # Parsed response of +GET /series+.
      class SeriesListResponse < Model
        field :error_text
        field :message
        field :list, type: [Series], default: []
      end
    end
  end
end
