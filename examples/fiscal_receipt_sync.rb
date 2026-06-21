# frozen_string_literal: true

# Exemplu: emiterea unui bon fiscal cu încasare mixtă (sincron).
#
# Bonul fiscal se emite tot prin POST /payment cu type='Bon'. Pe lângă
# produsele vândute, se pot specifica sumele încasate pe fiecare metodă
# de plată (cash, card, tichete de masă etc.) prin câmpurile received_*.
# Dacă return_fiscal_printer_text: true, API-ul returnează textul
# destinat imprimantei fiscale (în message).

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

def main
  Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN").with_client do |client|
    payment = Smartbill::Sdk::Models::Payment.new(
      company_vat_code: "RO12345678",
      value: 260.0,
      type: "Bon",
      is_cash: false,
      use_stock: false,
      return_fiscal_printer_text: true,
      products: [
        Smartbill::Sdk::Models::Product.new(
          name: "Produs 1", measuring_unit_name: "buc", currency: "RON",
          quantity: 1, price: 200, is_tax_included: true,
          tax_name: "Normala", tax_percentage: 19
        ),
        Smartbill::Sdk::Models::Product.new(
          name: "Produs 2", measuring_unit_name: "buc", currency: "RON",
          quantity: 1, price: 60, is_tax_included: true,
          tax_name: "Normala", tax_percentage: 19
        )
      ],
      received_cash: 200.0,
      received_card: 60.0
    )

    receipt = client.payments.create(payment)
    puts "Bon fiscal emis: id=#{receipt.id}"
    puts "  Text imprimanta fiscala: #{receipt.message}"

    # Starea plății pentru o factură deja existentă.
    status = client.invoices.payment_status("RO12345678", "FCT", "0040")
    puts "Stare plata factura: total=#{status.invoice_total_amount}, " \
         "platit=#{status.paid_amount}, rest=#{status.unpaid_amount}"
  end
end

main if __FILE__ == $PROGRAM_NAME
