# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /payment+.
      #
      # Covers general incasari, chitanta, and bon fiscal. Fields unused for
      # a given +type+ are simply left as nil. Bon-fiscal +received_*+ fields
      # are all optional and default to 0 on the server side.
      class Payment < Struct
        attribute :company_vat_code, Types::Strict::String
        attribute :client, Client.optional.default(nil)
        attribute :issue_date, Types::Strict::String.optional.default(nil)
        attribute :currency, Types::Strict::String.optional.default(nil)
        attribute :language, Types::Strict::String.optional.default(nil)
        attribute :exchange_rate, Types::Coercible::Float.optional.default(nil)
        attribute :precision, Types::Coercible::Integer.optional.default(nil)
        attribute :issuer_cnp, Types::Strict::String.optional.default(nil)
        attribute :series_name, Types::Strict::String.optional.default(nil)
        attribute :number, Types::Strict::String.optional.default(nil)
        attribute :value, Types::Coercible::Float.optional.default(nil)
        attribute :text, Types::Strict::String.optional.default(nil)
        attribute :translated_text, Types::Strict::String.optional.default(nil)
        attribute :is_draft, Types::Strict::Bool.optional.default(nil)
        attribute :type, Types::Strict::String.optional.default(nil)
        attribute :is_cash, Types::Strict::Bool.optional.default(nil)
        attribute :observation, Types::Strict::String.optional.default(nil)
        attribute :use_invoice_details, Types::Strict::Bool.optional.default(nil)
        attribute :invoices_list, Types::Array.of(InvoiceRef).optional.default(nil)
        # Bon fiscal
        attribute :return_fiscal_printer_text, Types::Strict::Bool.optional.default(nil)
        attribute :use_stock, Types::Strict::Bool.optional.default(nil)
        attribute :products, Types::Array.of(Product).optional.default(nil)
        attribute :received_cash, Types::Coercible::Float.optional.default(nil)
        attribute :received_card, Types::Coercible::Float.optional.default(nil)
        attribute :received_tichete_masa, Types::Coercible::Float.optional.default(nil)
        attribute :received_tichete_cadou, Types::Coercible::Float.optional.default(nil)
        attribute :received_ordin_de_plata, Types::Coercible::Float.optional.default(nil)
        attribute :received_cec, Types::Coercible::Float.optional.default(nil)
        attribute :received_credit, Types::Coercible::Float.optional.default(nil)
        attribute :received_cupon, Types::Coercible::Float.optional.default(nil)
        attribute :received_puncte_de_fidelitate, Types::Coercible::Float.optional.default(nil)
        attribute :received_bonuri_valoare_fixa, Types::Coercible::Float.optional.default(nil)
        attribute :received_moneda_alternativa, Types::Coercible::Float.optional.default(nil)
      end
    end
  end
end
