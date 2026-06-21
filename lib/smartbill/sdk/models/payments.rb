# frozen_string_literal: true

require_relative "base"
require_relative "common"

module Smartbill
  module Sdk
    module Models
      # Request body for +POST /payment+.
      #
      # Covers general incasari, chitanta, and bon fiscal. Fields unused for
      # a given +type+ are simply left as nil. Bon-fiscal +received_*+ fields
      # are all optional and default to 0 on the server side.
      class Payment < Model
        field :company_vat_code, required: true
        field :client, type: Client
        field :issue_date
        field :currency
        field :language
        field :exchange_rate
        field :precision
        field :issuer_cnp
        field :series_name
        field :number
        field :value
        field :text
        field :translated_text
        field :is_draft
        field :type
        field :is_cash
        field :observation
        field :use_invoice_details
        field :invoices_list, type: [InvoiceRef]
        # Bon fiscal
        field :return_fiscal_printer_text
        field :use_stock
        field :products, type: [Product]
        field :received_cash
        field :received_card
        field :received_tichete_masa
        field :received_tichete_cadou
        field :received_ordin_de_plata
        field :received_cec
        field :received_credit
        field :received_cupon
        field :received_puncte_de_fidelitate
        field :received_bonuri_valoare_fixa
        field :received_moneda_alternativa
      end
    end
  end
end
