# frozen_string_literal: true

# Exemplu: stornare, anulare, restaurare factură și descărcare PDF (sincron).
#
# Acest exemplu ilustrează operațiile secundare pe facturi:
#   * client.invoices.reverse(StornoRequest)  -> POST /invoice/reverse
#   * client.invoices.cancel(cif, series, number) -> PUT /invoice/cancel
#   * client.invoices.restore(cif, series, number) -> PUT /invoice/restore
#   * client.invoices.pdf(cif, series, number) -> GET /invoice/pdf (binary String)

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

def main
  Smartbill::Sdk::Client.new(username: "you@example.com", token: "YOUR_TOKEN").with_client do |client|
    cif = "RO12345678"
    series = "FCT"
    number = "0040"

    # 1. Stornare.
    storno = Smartbill::Sdk::Models::StornoRequest.new(
      company_vat_code: cif, series_name: series, number: number
    )
    st = client.invoices.reverse(storno)
    puts "Factura storno: #{st.series} #{st.number}"
    puts "  Document URL: #{st.document_url}"

    # 2. Anulare factură originală.
    client.invoices.cancel(cif, series, number)
    puts "Factura a fost anulata."

    # 3. Restaurare factură (se poate face ulterior).
    client.invoices.restore(cif, series, number)
    puts "Factura a fost restaurata."

    # 4. Descărcare PDF.
    pdf_bytes = client.invoices.pdf(cif, series, number)
    File.binwrite("factura.pdf", pdf_bytes)
    puts "PDF salvat (#{pdf_bytes.bytesize} bytes)."
  end
end

main if __FILE__ == $PROGRAM_NAME
