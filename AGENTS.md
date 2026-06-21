# PROJECT KNOWLEDGE BASE

**Generated:** 2026-06-21

## OVERVIEW
Project: **smartbill-sdk** (gem name `smartbill-sdk`, namespace `Smartbill::Sdk`)
Stack: Ruby ≥ 3.2, stdlib `Net::HTTP` + `base64` + `json`; build via Bundler/gemspec;
tests with `minitest` + `WebMock`; lint with `RuboCop`.

A Ruby SDK for the [SmartBill Cloud REST API](https://www.facturionline.ro/api-program-facturare/)
offering a **synchronous** `Smartbill::Sdk::Client` with typed request/response
models covering every endpoint in the official `openapi.json` spec. It is a
faithful Ruby port of the Python `smartbill-rest-sdk`
(see `/home/dnutiu/PycharmProjects/smartbill-sdk`).

## STRUCTURE
```
lib/smartbill/sdk.rb               # entry point (require "smartbill/sdk")
lib/smartbill/sdk/version.rb       # VERSION
lib/smartbill/sdk/exceptions.rb    # Error hierarchy (Error, AuthError, RateLimitError, APIError, TransportError, ValidationError)
lib/smartbill/sdk/transport.rb     # Request/Response structs, build_auth, build_request, parse_envelope, handle_response, RateLimiter
lib/smartbill/sdk/http_adapter.rb  # NetHttpAdapter (default HTTP adapter) + Response struct
lib/smartbill/sdk/client.rb        # Smartbill::Sdk::Client (sync) + services wiring
lib/smartbill/sdk/models.rb        # requires all models
lib/smartbill/sdk/models/
  base.rb        # Model base class + `field` DSL (snake_case attrs <-> camelCase JSON)
  enums.rb       # PaymentType, DocumentType, DiscountType (string/int constants)
  common.rb      # Client, Product, InvoiceRef, InvoicePayment
  invoices.rb    # Invoice, StornoRequest
  estimates.rb   # Estimate
  payments.rb    # Payment
  email.rb       # EmailDocument
  config.rb      # Tax, Series, TaxesResponse, SeriesListResponse
  stocks.rb      # StockProduct, StockWarehouse, StockList, StocksResponse
  responses.rb   # BaseResponse, InvoiceCreateResponse, StornoResponse, PaymentStatusResponse, ProformaInvoicesResponse, EmailStatus, EmailResponse, FiscalReceiptResponse
lib/smartbill/sdk/services.rb      # InvoicesService, EstimatesService, PaymentsService, EmailService, ConfigurationService, StocksService
test/                             # minitest + WebMock suite (60 tests)
examples/                         # standalone runnable Ruby scripts
skills/                           # pi agent skills (SKILL.md per API area)
sig/smartbill/sdk.rbs             # RBS signature stub (not yet filled in)
```

## COMMANDS
| Action              | Command                          |
|---------------------|----------------------------------|
| Install (dev)       | `bundle install`                 |
| Run tests           | `bundle exec rake test`          |
| Run a single test   | `bundle exec ruby -Ilib:test test/smartbill/test_invoices.rb` |
| Lint                | `bundle exec rubocop`            |
| Auto-correct lint   | `bundle exec rubocop -A`         |
| Build gem           | `bundle exec rake build`         |
| Console             | `bin/console`                    |
| Run an example      | `bundle exec ruby examples/create_invoice_sync.rb` |

## CODING STANDARDS
*   **Language**: Ruby 3.2+; `# frozen_string_literal: true` everywhere.
*   **Style**: 2-space indent, double-quote strings (enforced by RuboCop).
*   **Models**: subclass `Smartbill::Sdk::Models::Model` and declare fields
    with `field :snake_name, json_key: "camelCase", required: ..., type: ...`.
    `type:` is a Model subclass for nested objects, or `[ModelSubclass]` for
    arrays of nested objects. Serialize with `#to_h` (camelCase keys, nils
    excluded) or `#to_json`. Input accepts snake_case, camelCase and extra
    `input_keys:` aliases (e.g. `InvoiceRef` accepts both `seriesName` and
    `series`). Unknown input keys are preserved as extras.
*   **Enums**: plain modules of string/int constants (`PaymentType::CHITANTA`
    == `"Chitanta"`). Pass the constant; it is stored/serialized as-is.
*   **Services**: each service builds a `Transport::Request` via
    `Transport.build_request(...)` and parses the response with
    `Services.parse(payload, ModelClass)`. Services get the client (executor)
    injected; they call `@client.execute(request, binary: ...)`.
*   **Errors**: raise `Smartbill::Sdk::Error` subclasses from
    `exceptions.rb`; never bare `RuntimeError`. `Transport.handle_response`
    is the single place that maps HTTP status / envelopes to exceptions.
*   **HTTP adapter**: the client talks to a swappable adapter through one
    method `#call(req) -> Response`. The default is `NetHttpAdapter`
    (stdlib `Net::HTTP`). Inject a custom `http:` object in tests/for other
    backends.

## WHERE TO LOOK
*   **Source**: `lib/smartbill/sdk/`
*   **Tests**: `test/` (HTTP mocked via WebMock; `test/test_helper.rb` has
    shared helpers: `make_client`, `envelope`, `last_request`, `query_of`,
    `assert_auth`, `assert_json_headers`)
*   **Docs**: `README.md`, `examples/`
*   **Public API surface**: `lib/smartbill/sdk.rb` and `Smartbill::Sdk::Client`

## NOTES
*   **Auth**: HTTP Basic Auth with `username:token` where `username` is the
    login e-mail and `token` comes from SmartBill Cloud → *Contul Meu →
    Integrari → API*.
*   **JSON only**: the SDK sends JSON; XML is not supported.
*   **Rate limit**: 30 calls / 10 seconds — exceeding it triggers a
    server-side 403 that blocks access for 10 minutes. Opt into a
    client-side preemptive limiter with `Client.new(..., enforce_rate_limit: true)`.
*   **Dates**: all date fields are `YYYY-MM-DD` strings, matching the API.
*   **Sync only**: there is no async client (Ruby's concurrency model
    differs from Python's asyncio). For concurrency, run independent
    requests on separate threads — `Net::HTTP` opens a fresh connection
    per request so this is safe (see `examples/taxes_and_stocks_sync.rb`).
*   **`taxes` / `series` alias**: on a `Client`, `client.taxes` and
    `client.series` are the *same* `ConfigurationService` instance.
*   **Tests are mocked**: no network calls; WebMock intercepts `Net::HTTP`.
    The full suite (60 tests) passes offline.
*   **`base64` is a runtime dependency**: it stopped being a default gem in
    Ruby 3.4+, so it is declared in the gemspec.
*   **Port origin**: this codebase was ported from the Python
    `smartbill-rest-sdk`; behavior, models and endpoint coverage match.
*   **Agent skills**: `skills/` ships three pi `SKILL.md` files
    (`smartbill-invoices`, `smartbill-payments`, `smartbill-email`) that
    teach coding agents how to use the SDK, with Ruby code snippets.
*   No other context files (`.cursorrules`, `CLAUDE.md`, etc.) exist.
