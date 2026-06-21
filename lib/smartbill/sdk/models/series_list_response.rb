# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Parsed response of +GET /series+.
      class SeriesListResponse < Struct
        attribute :error_text, Types::Strict::String.optional.default(nil)
        attribute :message, Types::Strict::String.optional.default(nil)
        attribute :list, Types::Array.of(Series).default([].freeze)
      end
    end
  end
end
