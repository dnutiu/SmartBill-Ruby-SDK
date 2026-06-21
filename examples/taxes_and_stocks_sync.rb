# frozen_string_literal: true

# Exemplu: listarea taxelor (TVA) și a stocurilor (sincron, concurent).
#
# Echivalentul Ruby al exemplelor asincrone din Python. Ruby nu are un
# client async dedicat în acest SDK, dar operațiile independente pot fi
# rulate concurent cu thread-uri (fiecare thread folosește propriul
# Smartbill::Sdk::Client, sau clientul shared — Net::HTTP deschide o
# conexiune nouă per request, deci este thread-safe în această privință).

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

CIF = "RO12345678"

def fetch_taxes(client)
  client.taxes.taxes(CIF)
end

def fetch_stocks(client)
  client.stocks.get(CIF, "2024-05-01")
end

def main
  client = Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN")

  taxes_thread = Thread.new { fetch_taxes(client) }
  stocks_thread = Thread.new { fetch_stocks(client) }

  taxes = taxes_thread.value
  stocks = stocks_thread.value

  puts "Taxe:"
  taxes.taxes.each { |t| puts "  - #{t.name}: #{t.percentage}%" }

  puts "Stocuri:"
  stocks.list.each do |entry|
    wh = entry.warehouse
    puts "  Gestiune: #{wh&.warehouse_name} (#{wh&.warehouse_type})"
    entry.products.each do |p|
      puts "    - #{p.product_name} [#{p.product_code}]: #{p.quantity} #{p.measuring_unit}"
    end
  end
ensure
  client&.close
end

main if __FILE__ == $PROGRAM_NAME
