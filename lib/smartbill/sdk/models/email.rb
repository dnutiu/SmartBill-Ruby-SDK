# frozen_string_literal: true

require_relative "base"
require_relative "enums"

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /document/send+.
      #
      # +subject+ and +body_text+ should be Base64-encoded by the caller
      # (as required by the SmartBill API).
      class EmailDocument < Model
        field :company_vat_code, required: true
        field :series_name, required: true
        field :number, required: true
        field :type
        field :subject
        field :to
        field :cc
        field :bcc
        field :body_text
      end
    end
  end
end
