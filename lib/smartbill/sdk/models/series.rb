# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # A document series entry from +GET /series+.
      class Series < Model
        field :name
        field :next_number
        field :type
      end
    end
  end
end
