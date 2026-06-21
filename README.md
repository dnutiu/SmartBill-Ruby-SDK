# smartbill-sdk

A Ruby SDK for the [SmartBill Cloud REST API](https://www.facturionline.ro/api-program-facturare/),
offering a synchronous client with typed request/response models covering
every endpoint in the official `openapi.json` spec.

This is a Ruby port of the Python
[`smartbill-rest-sdk`](https://github.com/dnutiu/smartbill-sdk).

## Features

- Synchronous `Smartbill::Sdk::Client`.
- Typed request/response models built on **dry-struct** (type coercion,
  required-attribute presence, snake_case ⇄ camelCase aliasing) with
  **dry-validation** contracts enforcing semantic rules (date formats,
  payment-type enum, positive amounts, recipient e-mail shape) before
  every request is sent.
- snake_case Ruby attributes aliased to camelCase JSON automatically
  (`company_vat_code` ↔ `companyVatCode`).
- Permissive parsing — unknown API fields are ignored, so new fields
  don't break parsing.
- Helper exception hierarchy with the API `errorText` surfaced.
- Optional client-side rate limiter (SmartBill allows 30 calls / 10s,
  then blocks for 10 minutes).
- Runtime dependencies: `dry-struct`, `dry-validation`, `dry-types`,
  `dry-inflector`, `zeitwerk` (autoloading), and the stdlib `base64`
  gem (uses `Net::HTTP` under the hood).

## Installation

Add to your application's Gemfile:

```ruby
gem "smartbill-sdk"
```

Or install manually:

```bash
gem install smartbill-sdk
```

From source (development):

```bash
bundle install
bundle exec rake test      # run the test suite
```

## Authentication

SmartBill uses HTTP Basic Auth with `username:token`:

- `username` — the e-mail you log in with in SmartBill Cloud.
- `token` — found in SmartBill Cloud > **Contul Meu** > **Integrari** > **API**.

```ruby
require "smartbill/sdk"

client = Smartbill::Sdk::Client.new(username: "you@example.com", token: "abc123...")
```

## Quick start

```ruby
require "smartbill/sdk"

include Smartbill::Sdk

client = Client.new(username: "you@example.com", token: "...")

invoice = Models::Invoice.new(
  company_vat_code: "RO12345678",
  client: Models::Client.new(name: "Intelligent IT", vat_code: "RO12345678",
                             city: "Sibiu", country: "Romania"),
  series_name: "FCT",
  is_draft: false,
  products: [
    Models::Product.new(name: "Produs 1", measuring_unit_name: "buc", currency: "RON",
                        quantity: 2, price: 10, is_tax_included: true,
                        tax_name: "Redusa", tax_percentage: 9)
  ]
)

resp = client.invoices.create(invoice)
puts "Factura emisa: seria #{resp.series}, numarul #{resp.number}"
```

The client can also be used with a block that closes it automatically:

```ruby
Client.new(username: "...", token: "...").with_client do |c|
  c.invoices.create(invoice)
end
```

## Services

| Attribute          | Service                  | Covers                                                        |
|--------------------|--------------------------|---------------------------------------------------------------|
| `client.invoices`  | `InvoicesService`        | create, delete, reverse (storno), cancel, restore, payment status, PDF |
| `client.estimates` | `EstimatesService`       | create, delete, cancel, restore, PDF, invoices-status         |
| `client.payments`  | `PaymentsService`        | create (general / chitanta / bon fiscal), delete, fiscal-receipt text |
| `client.email`     | `EmailService`           | `POST /document/send`                                         |
| `client.taxes`     | `ConfigurationService`   | `GET /tax` (taxes), `GET /series` (series)                    |
| `client.series`    | `ConfigurationService`   | alias of `client.taxes` — same instance                       |
| `client.stocks`    | `StocksService`          | `GET /stocks`                                                 |

### Lifecycle: storno / cancel / restore / PDF

```ruby
storno = Models::StornoRequest.new(company_vat_code: cif, series_name: "FCT", number: "0040")
st = client.invoices.reverse(storno)
puts st.document_url

client.invoices.cancel(cif, "FCT", "0040")     # PUT /invoice/cancel
client.invoices.restore(cif, "FCT", "0040")    # PUT /invoice/restore

pdf_bytes = client.invoices.pdf(cif, "FCT", "0040")  # raw binary String
File.binwrite("factura.pdf", pdf_bytes)
```

### Taxes, series and stocks

```ruby
taxes = client.taxes.taxes("RO12345678")
taxes.taxes.each { |t| puts "#{t.name}: #{t.percentage}%" }

series = client.series.series("RO12345678", type: "f")  # type: f/c/p/i/n
series.list.each { |s| puts "#{s.name}: #{s.next_number}" }

stocks = client.stocks.get("RO12345678", "2024-05-01", warehouse_name: "Depozit")
stocks.list.each { |entry| entry.products.each { |p| puts p.product_name } }
```

### E-mail

`subject` and `body_text` must be Base64-encoded by the caller, as the
SmartBill API requires.

```ruby
email = Models::EmailDocument.new(
  company_vat_code: "RO12345678", series_name: "FCT", number: "0040",
  type: Models::DocumentType::INVOICE, to: "client@example.ro",
  subject: Base64.strict_encode64("Factura FCT0040"),
  body_text: Base64.strict_encode64("Va trimitem Factura FCT0040.")
)
resp = client.email.send(email)
puts resp.status.code, resp.status.message
```

## Errors

All errors descend from `Smartbill::Sdk::Error`:

- `AuthError` — HTTP 401 (bad username/token/company CIF).
- `RateLimitError` — HTTP 403 (rate-limited, blocked 10 min).
- `APIError` — has `.error_text`, `.message_field`, `.status_code`
  (the API's `errorText` is surfaced in `.error_text`).
- `TransportError` — network-level failure.
- `ValidationError` — a model is missing required fields or fails its
  validation contract (bad date format, unknown payment type, non-positive
  amount, etc.). Raised before any HTTP call is made.

```ruby
rescue Smartbill::Sdk::AuthError => e
  # ...
rescue Smartbill::Sdk::APIError => e
  puts e.error_text, e.status_code
end
```

## Validation

Request models are checked against a dry-validation contract before being
sent, so malformed requests raise `ValidationError` locally instead of
round-tripping to the SmartBill API. The contracts enforce:

- date fields match `YYYY-MM-DD`;
- `Payment#type` is one of the SmartBill payment types;
- `EmailDocument#type` is `factura` / `proforma` and recipients look like
  e-mail addresses;
- numeric amounts are positive; `precision` is a non-negative integer;
- nested payment-at-issuance blocks (`Invoice#payment`) are validated too.

You can also run a contract explicitly:

```ruby
Smartbill::Sdk::Contracts::InvoiceContract.validate!(invoice) # raises ValidationError
result = Smartbill::Sdk::Contracts::InvoiceContract.new.call(invoice.to_attributes)
result.success?  # => true / false
result.errors.to_h  # => { issue_date: ["is in invalid format"] }
```

## Rate limiting

SmartBill allows 30 calls / 10 seconds; exceeding it triggers a server-side
403 that blocks access for 10 minutes. Opt into a client-side preemptive
limiter with `enforce_rate_limit:`:

```ruby
client = Smartbill::Sdk::Client.new(username: "...", token: "...", enforce_rate_limit: true)
```

## Notes

- The SDK talks JSON only (`format="json"`); XML is not supported.
- All date fields use `YYYY-MM-DD` strings, matching the API.
- Only a synchronous client is provided. For concurrency, run
  independent requests on separate threads (each `Net::HTTP` request
  opens its own connection — see `examples/taxes_and_stocks_sync.rb`).

## Examples

Runnable scripts live in [`examples/`](examples/):

| Script                          | Demonstrates                                   |
|---------------------------------|------------------------------------------------|
| `create_invoice_sync.rb`        | Issuing an invoice                             |
| `create_estimate_sync.rb`       | Issuing a proforma + invoices-status           |
| `create_payment_sync.rb`        | Registering a `Chitanta` payment              |
| `invoice_lifecycle_sync.rb`     | Storno / cancel / restore / PDF                |
| `list_series_sync.rb`           | `GET /series`                                  |
| `send_email_sync.rb`            | `POST /document/send` with Base64             |
| `fiscal_receipt_sync.rb`        | `Bon fiscal` with mixed cash/card payment      |
| `taxes_and_stocks_sync.rb`      | Concurrent `GET /tax` + `GET /stocks` via threads |

## Agent skills

This repo ships ready-to-import [pi](https://github.com/earendil-works/pi-coding-agent)
**skills** under [`skills/`](skills/) that teach coding agents how to use
the SDK. Each `SKILL.md` is a self-contained, copy-pasteable guide for one
area of the API:

| Skill                | Covers                                                                  |
|----------------------|-------------------------------------------------------------------------|
| `smartbill-invoices` | Invoices & proformas/estimates: create, storno, cancel, restore, PDF, payment status |
| `smartbill-payments` | Payments & fiscal receipts (`bon fiscal`): `POST /payment`, payment types, mixed cash/card, fiscal-printer text, delete |
| `smartbill-email`    | Emailing a document (`POST /document/send`): base64 subject/body, invoice/proforma |

See [`skills/README.md`](skills/README.md) for how to import them into a pi
agent. The runnable scripts in [`examples/`](examples/) accompany these
skills.

## Disclaimer

This SDK was written by an AI agent (pi) as a Ruby port of the Python
`smartbill-rest-sdk`, which was itself generated from the official
`openapi.json` spec. The Ruby port is verified with a suite of 60 mocked
tests (using WebMock). Please have a human review it before issuing real
invoices — accountants work hard enough as it is.

## License

The gem is available as open source under the terms of the
[MIT License](LICENSE.txt).
