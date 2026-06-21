# frozen_string_literal: true

# Exemplu: emiterea unei facturi simple (sincron).
#
# Acest script arată cum se creează și se emite o factură nouă folosind
# clientul sincron Smartbill::Sdk::Client. Factura conține un singur produs
# cu TVA inclus (cota redusă) și este emisă direct (is_draft: false).
#
# Câmpurile din modele folosesc snake_case în Ruby, dar sunt serializate
# automat în camelCase către API (ex. company_vat_code devine companyVatCode).

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

def main
  # 1. Autentificare (HTTP Basic Auth: username:token).
  client = Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN")

  # 2. Construirea facturii.
  invoice = Smartbill::Sdk::Models::Invoice.new(
    company_vat_code: "RO12345678",
    client: Smartbill::Sdk::Models::Client.new(
      name: "Intelligent IT",
      vat_code: "RO12345678",
      address: "str. Sperantei, nr. 5",
      city: "Sibiu",
      county: "Sibiu",
      country: "Romania",
      email: "office@intelligent.ro"
    ),
    series_name: "FCT",
    is_draft: false,
    issue_date: "2024-05-01",
    due_date: "2024-05-15",
    products: [
      Smartbill::Sdk::Models::Product.new(
        name: "Produs 1",
        code: "ccd1",
        measuring_unit_name: "buc",
        currency: "RON",
        quantity: 2,
        price: 10,
        is_tax_included: true,
        tax_name: "Redusa",
        tax_percentage: 9
      )
    ]
  )

  # 3. Emiterea facturii.
  client.with_client do |c|
    resp = c.invoices.create(invoice)
    puts "Factura emisa: seria #{resp.series}, numarul #{resp.number}"
  end
end

main if __FILE__ == $PROGRAM_NAME
