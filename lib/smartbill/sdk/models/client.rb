# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Client data (+client+ / +clientMin+).
      class Client < Struct
        attribute :name, Types::Strict::String
        attribute :vat_code, Types::Strict::String.optional.default(nil)
        attribute :code, Types::Strict::String.optional.default(nil)
        attribute :address, Types::Strict::String.optional.default(nil)
        attribute :reg_com, Types::Strict::String.optional.default(nil)
        attribute :is_tax_payer, Types::Strict::Bool.optional.default(nil)
        attribute :contact, Types::Strict::String.optional.default(nil)
        attribute :phone, Types::Strict::String.optional.default(nil)
        attribute :city, Types::Strict::String.optional.default(nil)
        attribute :county, Types::Strict::String.optional.default(nil)
        attribute :country, Types::Strict::String.optional.default(nil)
        attribute :email, Types::Strict::String.optional.default(nil)
        attribute :bank, Types::Strict::String.optional.default(nil)
        attribute :iban, Types::Strict::String.optional.default(nil)
        attribute :save_to_db, Types::Strict::Bool.optional.default(nil)
      end
    end
  end
end
