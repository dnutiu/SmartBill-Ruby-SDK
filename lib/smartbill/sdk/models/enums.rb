# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Document type for the e-mail endpoint.
      module DocumentType
        INVOICE = "factura"
        PROFORMA = "proforma"
      end

      # Possible values for +type+ on payments / incasari.
      module PaymentType
        CHITANTA = "Chitanta"
        BON = "Bon"
        CARD = "Card"
        CARD_ONLINE = "Card online"
        CEC = "CEC"
        BILET_ORDIN = "Bilet ordin"
        ORDIN_PLATA = "Ordin plata"
        MANDAT_POSTAL = "Mandat postal"
        EXTRAS_DE_CONT = "Extras de cont"
        RAMBURS = "Ramburs"
        ALTA_INCASARE = "Alta incasare"
      end

      # Discount type: 1 = valoric, 2 = procentual.
      module DiscountType
        VALORIC = 1
        PROCENTUAL = 2
      end
    end
  end
end
