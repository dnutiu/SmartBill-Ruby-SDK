# frozen_string_literal: true

# Exemplu: emiterea unei facturi în RON cu un produs cu preț de referință în
# EUR (sincron).
#
# Acest script arată cum se emite o factură a cărei monedă este RON, dar al
# cărei produs are prețul de referință în EUR. SmartBill convertește
# automat folosind cursul BNR din data emiterii (când nu se specifică
# `exchange_rate` pe produs), sau se poate da un curs explicit.
#
# Tiparul corespunde definiției `exempluFacturaPreturiValuta` din
# `docs/openapi.json`: produsul are `currency: "EUR"`, iar factura are
# `currency: "RON"`.
#
# `is_draft: true` salvează factura ca ciornă (fără număr, neemitcă către
# ANAF) — sigur pentru teste pe cont real. Pentru emitere finală, folosește
# `is_draft: false`.

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

# TODO: înlocuiește cu datele tale.
USERNAME = "you@example.com"
TOKEN = "YOUR_TOKEN"
COMPANY_VAT_CODE = "52859275"     # CIF-ul firmei tale (emitentul)
CLIENT_VAT_CODE = "RO46548525"    # CIF-ul clientului
SERIES_NAME = "ABC"

# Cursul EUR->RON. Lasă-l `nil` pentru a lăsa SmartBill să folosească cursul
# BNR din data emiterii. Dacă API-ul cere un curs explicit, setează-l aici,
# de ex. `EXCHANGE_RATE = 5.05`.
EXCHANGE_RATE = nil

def build_product(name:, price_eur:, quantity:, exchange_rate:)
  attrs = {
    name: name,
    is_service: true,
    measuring_unit_name: "ore",
    currency: "EUR",            # moneda prețului de referință
    price: price_eur,           # preț unitar în EUR (fără TVA)
    quantity: quantity,
    is_tax_included: false,     # B2B: preț fără TVA
    tax_name: "Normala",
    tax_percentage: 19
  }
  attrs[:exchange_rate] = exchange_rate unless exchange_rate.nil?
  Smartbill::Sdk::Models::Product.new(**attrs)
end

def build_invoice
  product = build_product(
    name: "Servicii de dezvoltare software",
    price_eur: 31,
    quantity: 168,
    exchange_rate: EXCHANGE_RATE
  )

  Smartbill::Sdk::Models::Invoice.new(
    company_vat_code: COMPANY_VAT_CODE,
    client: Smartbill::Sdk::Models::Client.new(
      name: "Intelligent IT",
      vat_code: CLIENT_VAT_CODE,
      city: "Sibiu",
      county: "Sibiu",
      country: "Romania",
      address: "str. Sperantei, nr. 5",
      email: "office@intelligent.ro"
    ),
    series_name: SERIES_NAME,
    is_draft: true,             # ciornă: salvată, nefinalizată, fără număr
    issue_date: Time.now.strftime("%Y-%m-%d"),
    due_date: (Time.now + (86_400 * 15)).strftime("%Y-%m-%d"),
    currency: "RON",            # moneda documentului
    mentions: "Nota Comanda Nr. 1 din 11.05.2026, Contract WP271",
    products: [product]
  )
end

def main
  Smartbill::Sdk::Client.new(username: USERNAME, token: TOKEN).with_client do |client|
    invoice = build_invoice
    resp = client.invoices.create(invoice)

    if resp.number && !resp.number.empty?
      puts "Factura finalizată: seria #{resp.series}, numărul #{resp.number}"
    else
      # La ciornă, `number` este gol — factura a fost doar salvată.
      puts "Factura salvată în ciornă (seria #{resp.series})."
    end
    puts "Mesaj API: #{resp.message}" if resp.message
  end
rescue Smartbill::Sdk::AuthError => e
  warn "Eroare autentificare (401): #{e.message}"
rescue Smartbill::Sdk::APIError => e
  warn "Eroare API [#{e.status_code}]: #{e.error_text}"
rescue Smartbill::Sdk::ValidationError => e
  warn "Eroare validare: #{e.message}"
end

main
