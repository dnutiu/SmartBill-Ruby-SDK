# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /document/send+.
      #
      # +subject+ and +body_text+ should be Base64-encoded by the caller
      # (as required by the SmartBill API).
      class EmailDocument < Struct
        attribute :company_vat_code, Types::Strict::String
        attribute :series_name, Types::Strict::String
        attribute :number, Types::Strict::String
        attribute :type, Types::Strict::String.optional.default(nil)
        attribute :subject, Types::Strict::String.optional.default(nil)
        attribute :to, Types::Strict::String.optional.default(nil)
        attribute :cc, Types::Strict::String.optional.default(nil)
        attribute :bcc, Types::Strict::String.optional.default(nil)
        attribute :body_text, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
