# frozen_string_literal: true

# Exemplu: listarea seriilor de documente (sincron).
#
# Endpoint: GET /series. Returnează seriile (și următorul număr liber)
# pentru documentele din cont. Parametrul opțional type filtrează după
# tipul documentului:
#   f - facturi, c - chitanțe, p - proforme, i - bonuri fiscale, n - avize
# Dacă type nu este dat, se returnează toate seriile.

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

def main
  Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN").with_client do |client|
    # Doar seriile de facturi.
    facturi = client.series.series("RO12345678", type: "f")
    puts "Serii facturi:"
    facturi.list.each { |s| puts "  - #{s.name}: urmatorul numar #{s.next_number}" }

    # Toate seriile (fără filtru).
    toate = client.series.series("RO12345678")
    puts "Total serii (orice tip): #{toate.list.size}"
  end
end

main if __FILE__ == $PROGRAM_NAME
