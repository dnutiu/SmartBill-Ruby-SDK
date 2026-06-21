# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Common envelope: +errorText+/+message+/+number+/+series+/+url+.
      class BaseResponse < Model
        field :error_text
        field :message
        field :number
        field :series
        field :url
      end
    end
  end
end
