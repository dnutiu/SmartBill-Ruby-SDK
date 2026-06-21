# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Parsed response of +GET /tax+.
      class TaxesResponse < Model
        field :error_text
        field :message
        field :taxes, type: [Tax], default: []
      end
    end
  end
end
