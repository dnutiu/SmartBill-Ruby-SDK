# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A VAT rate entry from +GET /tax+.
      class Tax < Model
        field :name
        field :percentage
        field :id
      end
    end
  end
end
