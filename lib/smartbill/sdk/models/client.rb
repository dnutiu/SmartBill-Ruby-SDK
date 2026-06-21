# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Client data (+client+ / +clientMin+).
      class Client < Model
        field :name, required: true
        field :vat_code
        field :code
        field :address
        field :reg_com
        field :is_tax_payer
        field :contact
        field :phone
        field :city
        field :county
        field :country
        field :email
        field :bank
        field :iban
        field :save_to_db
      end
    end
  end
end
