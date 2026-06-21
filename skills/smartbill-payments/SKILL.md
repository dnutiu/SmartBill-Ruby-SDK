---
name: smartbill-payments
description: Record payments and issue fiscal receipts (bon fiscal) via SmartBill using smartbill-sdk (Ruby). POST /payment, payment types, mixed cash/card, fiscal-printer text, delete.
---

# SmartBill Payments & Fiscal Receipts

Record payments against invoices and issue fiscal receipts (`bon fiscal`)
with the `smartbill-sdk` Ruby gem. Synchronous usage. Ruby has no async
client — for concurrency, run independent requests on separate threads.

## Setup

```bash
gem install smartbill-sdk
```

```ruby
require "smartbill/sdk"

client = Smartbill::Sdk::Client.new(username: "you@example.com", token: "...")
```

Auth is HTTP Basic `username:token` (token from SmartBill Cloud →
**Contul Meu → Integrari → API**). JSON only. Rate limit: 30 calls / 10s.

## Draft chitante (ciornă)

`Payment` accepts `is_draft` (API alias `isDraft`). This only applies to
`type: "Chitanta"`. When `is_draft: true` the chitanta is **saved but not
finalized** — it gets **no number** and appears in SmartBill Cloud under
**Rapoarte → Incasări** for a human to review and finalize. When
`is_draft: false` (the default), the chitanta is finalized and
`resp.number` / `resp.series` are populated.

```ruby
payment = Smartbill::Sdk::Models::Payment.new(
  company_vat_code: "RO12345678",
  series_name: "CHT",
  value: 260.0,
  type: "Chitanta",
  is_draft: true,       # ← ciornă: saved, not finalized, no number
  is_cash: true
)
resp = client.payments.create(payment)
# resp.number / resp.series are empty until finalized in SmartBill Cloud
```

`is_draft` is **not** meaningful for `type: "Bon"` (fiscal receipts) — those
are always issued immediately via the fiscal printer.

## The payments service

`client.payments` (`PaymentsService`) exposes:

| Method                  | Endpoint                  | Purpose                              |
|-------------------------|---------------------------|--------------------------------------|
| `create`                | `POST /payment`           | record a payment / issue bon fiscal  |
| `delete_other`          | `DELETE /payment/v2`      | delete a non-chitanta payment        |
| `delete_chitanta`       | `DELETE /payment/chitanta`| delete a chitanta                    |
| `fiscal_receipt_text`   | `GET /payment/text`       | fetch base64 fiscal-printer text by id |

## Payment types

`Payment#type=` is one of (string values, case-sensitive as documented):

`Chitanta`, `Bon`, `Card`, `Card online`, `CEC`, `Bilet ordin`,
`Ordin plata`, `Mandat postal`, `Extras de cont`, `Ramburs`,
`Alta incasare`.

(Also available as constants under `Smartbill::Sdk::Models::PaymentType`,
e.g. `Smartbill::Sdk::Models::PaymentType::CHITANTA` == `"Chitanta"`.)

## Record a simple payment (chitanta / card / etc.)

```ruby
payment = Smartbill::Sdk::Models::Payment.new(
  company_vat_code: "RO12345678",
  series_name: "FCT",          # invoice series the payment applies to
  number: "0040",              # invoice number
  value: 260.0,
  type: "Chitanta",
  is_cash: true
)
resp = client.payments.create(payment)
```

## Issue a fiscal receipt (bon fiscal) with mixed cash + card

A `Bon` is also created via `POST /payment`, but you add `products` and the
`received_*` breakdown. With `return_fiscal_printer_text: true` the response
includes the receipt `id` and the base64 fiscal-printer text in `message`.

```ruby
payment = Smartbill::Sdk::Models::Payment.new(
  company_vat_code: "RO12345678",
  value: 260.0,
  type: "Bon",
  is_cash: false,
  use_stock: false,
  return_fiscal_printer_text: true,
  products: [
    Smartbill::Sdk::Models::Product.new(
      name: "Produs 1", measuring_unit_name: "buc", currency: "RON",
      quantity: 1, price: 200, is_tax_included: true,
      tax_name: "Normala", tax_percentage: 19
    ),
    Smartbill::Sdk::Models::Product.new(
      name: "Produs 2", measuring_unit_name: "buc", currency: "RON",
      quantity: 1, price: 60, is_tax_included: true,
      tax_name: "Normala", tax_percentage: 19
    )
  ],
  received_cash: 200.0,
  received_card: 60.0
)
resp = client.payments.create(payment)
puts resp.id            # generated receipt id
puts resp.message       # base64 fiscal-printer text (if requested)
```

`create` returns a `FiscalReceiptResponse` (a `BaseResponse` + optional `id`),
so `resp.number`, `resp.series`, `resp.error_text` are also available.

## Linking a payment to one or more invoices

Set `invoices_list:` to an array of `InvoiceRef` pairs to apply the payment
to specific invoice(s):

```ruby
payment = Smartbill::Sdk::Models::Payment.new(
  company_vat_code: "RO12345678",
  client: Smartbill::Sdk::Models::Client.new(name: "Intelligent IT", vat_code: "RO12345678"),
  value: 62.0,
  type: Smartbill::Sdk::Models::PaymentType::ORDIN_PLATA,
  is_cash: false,
  invoices_list: [
    Smartbill::Sdk::Models::InvoiceRef.new(series_name: "FCT", number: "0040")
  ]
)
resp = client.payments.create(payment)
```

## Fetch fiscal-printer text by id (later)

```ruby
r = client.payments.fiscal_receipt_text("RO12345678", "12345")
puts r.message   # base64-encoded text
```

## Delete a payment

```ruby
# Non-chitanta (uses query params to identify the payment):
client.payments.delete_other(
  "RO12345678",
  payment_type: "Card",
  payment_date: "2026-06-21",
  payment_value: 100.0,
  client_name: "Intelligent IT",
  client_cif: "RO12345678",
  invoice_series: "FCT",
  invoice_number: "0040"
)

# Chitanta (identified by its own series + number):
client.payments.delete_chitanta("RO12345678", "CHI", "0001")
```

All `delete_other` keyword args except `payment_type:` are optional filters.

## Concurrency (threads)

Ruby has no asyncio client. For independent calls, run them on threads:

```ruby
t1 = Thread.new { client.payments.create(payment) }
t2 = Thread.new { client.invoices.payment_status("RO12345678", "FCT", "0040") }
receipt = t1.value
status = t2.value
```

## Errors

`Smartbill::Sdk::APIError` carries `.error_text` (the API's `errorText`),
`.message_field`, and `.status_code`. See `lib/smartbill/sdk/exceptions.rb`.

## Reference

- Source: `lib/smartbill/sdk/services.rb` (`PaymentsService`)
- Models: `lib/smartbill/sdk/models/payments.rb`, `common.rb`,
  `responses.rb` (`FiscalReceiptResponse`)
- Worked examples: `examples/create_payment_sync.rb`,
  `examples/fiscal_receipt_sync.rb`
