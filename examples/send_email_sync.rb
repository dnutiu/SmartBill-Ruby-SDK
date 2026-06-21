# frozen_string_literal: true

# Exemplu: trimiterea pe e-mail a unui document (sincron).
#
# Endpoint: POST /document/send. Modelul EmailDocument identifică
# documentul prin serie + număr + tip (factura sau proforma) și permite
# specificarea destinatarilor (to, cc, bcc) și a conținutului.
#
# Important: câmpurile subject și body_text trebuie să fie codificate
# Base64 de către apelant, conform cerințelor API-ului SmartBill.

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"
require "base64"

# Codifică un text în Base64 (necesar pentru subject/bodyText).
def b64(text)
  Base64.strict_encode64(text)
end

def main
  Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN").with_client do |client|
    email = Smartbill::Sdk::Models::EmailDocument.new(
      company_vat_code: "RO12345678",
      series_name: "FCT",
      number: "0040",
      type: Smartbill::Sdk::Models::DocumentType::INVOICE,
      to: "client@example.ro",
      cc: "contabilitate@example.ro",
      subject: b64("Factura FCT0040"),
      body_text: b64("Va trimitem Factura FCT0040. Multumim!")
    )

    resp = client.email.send(email)
    # status.code este "0" la succes.
    puts "Status cod: #{resp.status.code}, mesaj: #{resp.status.message}"
  end
end

main if __FILE__ == $PROGRAM_NAME
