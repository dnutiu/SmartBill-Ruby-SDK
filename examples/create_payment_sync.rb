# frozen_string_literal: true

# Exemplu: înregistrarea unei încasări pe o factură (sincron).
#
# Aici se emite o încasare de tip „Chitanta” care este legată de o factură
# existentă prin invoices_list (perechi serie + număr).
#
# Endpoint: POST /payment. Modelul Payment acoperă toate tipurile de
# încasări (chitanță, bon, card, ordin de plată etc.) prin câmpul type.
# Câmpurile care nu se aplică tipului ales se lasă nil.

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

def main
  Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN").with_client do |client|
    payment = Smartbill::Sdk::Models::Payment.new(
      company_vat_code: "RO12345678",
      client: Smartbill::Sdk::Models::Client.new(name: "Intelligent IT", vat_code: "RO12345678"),
      value: 62.0,
      type: Smartbill::Sdk::Models::PaymentType::CHITANTA,
      is_cash: true,
      invoices_list: [
        Smartbill::Sdk::Models::InvoiceRef.new(series_name: "FCT", number: "0040")
      ]
    )

    resp = client.payments.create(payment)
    puts "Incasare inregistrata: seria #{resp.series}, numarul #{resp.number}"

    # Ștergere chitanță (dacă ulterior se anulează).
    # client.payments.delete_chitanta("RO12345678", resp.series, resp.number)
  end
end

main if __FILE__ == $PROGRAM_NAME
