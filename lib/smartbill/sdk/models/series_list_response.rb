# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Parsed response of +GET /series+.
      class SeriesListResponse < Model
        field :error_text
        field :message
        field :list, type: [Series], default: []
      end
    end
  end
end
