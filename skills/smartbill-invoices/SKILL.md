---
name: smartbill-invoices
description: Issue and manage SmartBill invoices (and proformas/estimates) via smartbill-sdk (Ruby). Create, cancel, restore, storno, PDF, payment status.
---

# SmartBill Invoices & Estimates

Create, manage, and download SmartBill invoices and proformas (`estimates`)
with the `smartbill-sdk` Ruby gem. Covers synchronous usage. Ruby has no
async client — for concurrency, run independent requests on separate
threads (see `examples/taxes_and_stocks_sync.rb`).

## Setup

```bash
gem install smartbill-sdk
```

Auth is HTTP Basic with your SmartBill login e-mail and API token
(SmartBill Cloud → **Contul Meu → Integrari → API**).

```ruby
require "smartbill/sdk"

client = Smartbill::Sdk::Client.new(username: "you@example.com", token: "...")
```

All date fields are `YYYY-MM-DD` strings. The SDK sends JSON only (no XML).
SmartBill rate-limits to 30 calls / 10s → 403 for 10 min if exceeded; opt
into a client-side preemptive limiter with `enforce_rate_limit: true`.

## Drafts (ciornă)

Both `Invoice` and `Estimate` accept `is_draft` (API alias `isDraft`). When
`is_draft: true` the document is **saved but not finalized**: it gets **no
series number** and is not officially issued. It shows up in SmartBill Cloud
under **Rapoarte → Facturi / Proforme** so a human can review and finalize it
there. When `is_draft: false` (the default), the document is finalized and a
number is assigned — `resp.series` / `resp.number` are populated.

```ruby
invoice = Smartbill::Sdk::Models::Invoice.new(
  # ...,
  series_name: "FCT",
  is_draft: true
)
resp = client.invoices.create(invoice)
# resp.number / resp.series are empty until finalized in SmartBill Cloud
```

## Services available

| Attribute          | Service                  | Covers                                       |
|--------------------|--------------------------|----------------------------------------------|
| `client.invoices`  | `InvoicesService`        | `POST /invoice`, delete, reverse (storno), cancel, restore, payment status, PDF |
| `client.estimates` | `EstimatesService`       | `POST /estimate`, delete, cancel, restore, PDF, invoices-status |
| `client.payments`  | `PaymentsService`        | see the `smartbill-payments` skill           |
| `client.email`     | `EmailService`           | see the `smartbill-email` skill              |
| `client.taxes`     | `ConfigurationService`   | `GET /tax` (taxes), `GET /series` (series)   |
| `client.series`    | `ConfigurationService`   | alias of `client.taxes` — same instance      |
| `client.stocks`    | `StocksService`          | `GET /stocks`                                |

Note: `client.taxes` and `client.series` are the **same**
`ConfigurationService` instance — call `client.taxes.taxes(cif)` /
`client.taxes.series(cif)`.

## Create an invoice

```ruby
require "smartbill/sdk"

Smartbill::Sdk::Client.new(username: "you@example.com", token: "...").with_client do |client|
  invoice = Smartbill::Sdk::Models::Invoice.new(
    company_vat_code: "RO12345678",
    client: Smartbill::Sdk::Models::Client.new(
      name: "Intelligent IT", vat_code: "RO12345678",
      city: "Sibiu", country: "Romania"
    ),
    series_name: "FCT",
    is_draft: false,
    products: [
      Smartbill::Sdk::Models::Product.new(
        name: "Produs 1", measuring_unit_name: "buc", currency: "RON",
        quantity: 2, price: 10, is_tax_included: true,
        tax_name: "Redusa", tax_percentage: 9
      )
    ]
  )
  resp = client.invoices.create(invoice)
  puts "#{resp.series} #{resp.number}"  # series + assigned number
end
```

Proformas use `Estimate` + `client.estimates.create(estimate)` — same shape,
and also support `is_draft: true` to save a proforma ciornă.

## Lifecycle: storno / cancel / restore / PDF

```ruby
cif = "RO12345678"
series = "FCT"
number = "0040"

# Storno (reversal) — returns document URLs.
storno = Smartbill::Sdk::Models::StornoRequest.new(
  company_vat_code: cif, series_name: series, number: number
)
st = client.invoices.reverse(storno)
puts st.document_url

client.invoices.cancel(cif, series, number)     # PUT /invoice/cancel
client.invoices.restore(cif, series, number)    # PUT /invoice/restore

pdf_bytes = client.invoices.pdf(cif, series, number)  # raw binary String
File.binwrite("factura.pdf", pdf_bytes)
```

`pdf` returns a raw binary `String` (binary endpoint — not JSON).

## Payment status of an invoice

```ruby
status = client.invoices.payment_status(cif, series, number)
puts status.paid
puts status.invoice_total_amount
puts status.paid_amount
puts status.unpaid_amount
```

## Proforma → invoice conversion status

```ruby
status = client.estimates.invoices_status(cif, "PFC", "0001")
puts status.are_invoices_created
status.invoices.each { |inv| puts "#{inv.series_name} #{inv.number}" }
```

## Concurrency (threads)

Ruby has no asyncio client. For independent calls, run them on threads —
`Net::HTTP` opens a fresh connection per request, so this is safe:

```ruby
client = Smartbill::Sdk::Client.new(username: "...", token: "...")

t1 = Thread.new { client.invoices.payment_status("RO12345678", "FCT", "0040") }
t2 = Thread.new { client.taxes.taxes("RO12345678") }
status = t1.value
taxes = t2.value
```

Always call `client.close` (or use `with_client { ... }`) when done.

## Error handling

Errors are `Smartbill::Sdk::Error` subclasses from `Smartbill::Sdk::Exceptions`:

- `AuthError` — HTTP 401 (bad username/token/company CIF).
- `RateLimitError` — HTTP 403 (rate-limited, blocked 10 min).
- `APIError` — has `.error_text`, `.message_field`, `.status_code`
  (the API's `errorText` is surfaced in `.error_text`).
- `TransportError` — network-level failure.
- `ValidationError` — a model is missing required fields.

```ruby
rescue Smartbill::Sdk::AuthError => e
  # ...
rescue Smartbill::Sdk::APIError => e
  puts e.error_text, e.status_code
end
```

## Reference

- Source: `lib/smartbill/sdk/services.rb` (`InvoicesService`, `EstimatesService`)
- Models: `lib/smartbill/sdk/models/invoices.rb`, `estimates.rb`, `common.rb`
- Worked examples: `examples/create_invoice_sync.rb`,
  `examples/create_estimate_sync.rb`, `examples/invoice_lifecycle_sync.rb`
