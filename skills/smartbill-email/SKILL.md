---
name: smartbill-email
description: Send SmartBill documents (invoices/proformas) by email via smartbill-sdk (Ruby). POST /document/send, base64 subject/body, sync.
---

# SmartBill Email (document/send)

Email an existing SmartBill invoice or proforma to recipients using the
`smartbill-sdk` Ruby gem. Synchronous usage. Ruby has no async client — for
concurrency, run independent requests on separate threads.

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

## The email service

`client.email` (`EmailService`) exposes:

| Method  | Endpoint              | Purpose                       |
|---------|-----------------------|-------------------------------|
| `send`  | `POST /document/send` | email a document to recipients |

## ⚠️ Base64 requirement

The SmartBill API requires `subject` and `body_text` to be **Base64-encoded**
by the caller. The SDK does **not** do this for you — encode before passing:

```ruby
require "base64"

def b64(text)
  Base64.strict_encode64(text)
end
```

## Send an invoice

```ruby
require "smartbill/sdk"
require "base64"

def b64(text)
  Base64.strict_encode64(text)
end

Smartbill::Sdk::Client.new(username: "you@example.com", token: "...").with_client do |client|
  email = Smartbill::Sdk::Models::EmailDocument.new(
    company_vat_code: "RO12345678",
    series_name: "FCT",
    number: "0040",
    type: Smartbill::Sdk::Models::DocumentType::INVOICE,   # or DocumentType::PROFORMA
    to: "client@example.ro",
    cc: "contabilitate@example.ro",
    # bcc: "secret@example.ro",
    subject: b64("Factura FCT0040"),
    body_text: b64("Va trimitem factura FCT0040. Multumim!")
  )
  resp = client.email.send(email)
  puts resp.status.code, resp.status.message   # "0" == success
end
```

`type` selects which document to send:
`Smartbill::Sdk::Models::DocumentType::INVOICE` (`"factura"`) or
`Smartbill::Sdk::Models::DocumentType::PROFORMA` (`"proforma"`). The document
is identified by `series_name` + `number` + `type` + `company_vat_code`.

## Send a proforma

```ruby
require "smartbill/sdk"
require "base64"

def b64(text)
  Base64.strict_encode64(text)
end

Smartbill::Sdk::Client.new(username: "you@example.com", token: "...").with_client do |client|
  email = Smartbill::Sdk::Models::EmailDocument.new(
    company_vat_code: "RO12345678",
    series_name: "PFC",
    number: "0001",
    type: Smartbill::Sdk::Models::DocumentType::PROFORMA,
    to: "client@example.ro",
    subject: b64("Proforma PFC0001"),
    body_text: b64("Va trimitem proforma PFC0001.")
  )
  resp = client.email.send(email)
  puts resp.status.code, resp.status.message
end
```

## Response

`send` returns an `EmailResponse` whose `status` is an `EmailStatus` with
`code` (`"0"` on success) and `message`.

## Errors

`Smartbill::Sdk::APIError` carries `.error_text` (the API's `errorText`),
`.message_field`, and `.status_code`. See `lib/smartbill/sdk/exceptions.rb`.

## Reference

- Source: `lib/smartbill/sdk/services.rb` (`EmailService`)
- Models: `lib/smartbill/sdk/models/email.rb`, `responses.rb`
  (`EmailResponse`, `EmailStatus`), `enums.rb` (`DocumentType`)
- Worked example: `examples/send_email_sync.rb`
