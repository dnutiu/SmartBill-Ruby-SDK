# frozen_string_literal: true

# Exemplu: emiterea unei proforme (sincron).
#
# Proforma se creează cu Estimate și se trimite prin
# client.estimates.create(estimate) (POST /estimate). Structura este foarte
# asemănătoare cu o factură: client, serie, produse.
#
# Documentul poate fi convertit ulterior în factură; starea conversiei se
# verifică cu client.estimates.invoices_status(...).

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

def main
  Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN").with_client do |client|
    estimate = Smartbill::Sdk::Models::Estimate.new(
      company_vat_code: "RO12345678",
      client: Smartbill::Sdk::Models::Client.new(
        name: "Intelligent IT",
        vat_code: "RO12345678",
        email: "office@intelligent.ro"
      ),
      series_name: "PFC",
      is_draft: false,
      products: [
        Smartbill::Sdk::Models::Product.new(
          name: "Serviciu dezvoltare",
          measuring_unit_name: "ore",
          currency: "RON",
          quantity: 10,
          price: 150,
          is_tax_included: false,
          tax_name: "Normala",
          tax_percentage: 19
        )
      ]
    )

    resp = client.estimates.create(estimate)
    puts "Proforma emisa: seria #{resp.series}, numarul #{resp.number}"

    # Verificăm dacă proforma a fost deja convertită în factură.
    status = client.estimates.invoices_status("RO12345678", resp.series, resp.number)
    if status.are_invoices_created
      status.invoices.each { |inv| puts "  Factura generata: #{inv.series_name} #{inv.number}" }
    else
      puts "  Proforma nu a fost inca convertita in factura."
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
