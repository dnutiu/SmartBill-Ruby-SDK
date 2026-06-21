# PROJECT KNOWLEDGE BASE

**Generated:** 2026-06-21

## OVERVIEW
Project: **smartbill-sdk** (gem name `smartbill-sdk`, namespace `Smartbill::Sdk`)
Stack: Ruby ≥ 3.2, stdlib `Net::HTTP` + `base64` + `json`, models via
`dry-struct` + `dry-types` + `dry-inflector`, request validation via
`dry-validation`, autoloading via `zeitwerk`; build via Bundler/gemspec;
tests with `minitest` + `WebMock`; lint with `RuboCop`.

A Ruby SDK for the [SmartBill Cloud REST API](https://www.facturionline.ro/api-program-facturare/)
offering a **synchronous** `Smartbill::Sdk::Client` with typed request/response
models covering every endpoint in the official `openapi.json` spec. It is a
faithful Ruby port of the Python `smartbill-rest-sdk`
(see `/home/dnutiu/PycharmProjects/smartbill-sdk`).

## STRUCTURE

Constants under `Smartbill::Sdk` are **autoloaded by Zeitwerk** from
`lib/smartbill/sdk/`, following the **one file per constant** convention
(the entry file `lib/smartbill/sdk.rb` sets up a `Zeitwerk::Loader` with
`push_dir(..., namespace: Smartbill::Sdk)`). No `require_relative` chains —
constants resolve on first reference. Inflection overrides map `version.rb`
→ `VERSION` and `api_error.rb` → `APIError`.

```
lib/smartbill/sdk.rb                  # entry point: Zeitwerk loader setup + DEFAULT_BASE_URL alias
lib/smartbill/sdk/version.rb          # Smartbill::Sdk::VERSION
lib/smartbill/sdk/error.rb            # Smartbill::Sdk::Error (base)
lib/smartbill/sdk/auth_error.rb       # AuthError (HTTP 401)
lib/smartbill/sdk/rate_limit_error.rb # RateLimitError (HTTP 403)
lib/smartbill/sdk/transport_error.rb  # TransportError
lib/smartbill/sdk/validation_error.rb # ValidationError (missing required fields)
lib/smartbill/sdk/api_error.rb        # APIError (.error_text/.message_field/.status_code)
lib/smartbill/sdk/response.rb         # Response struct (status/body/content_type)
lib/smartbill/sdk/net_http_adapter.rb # NetHttpAdapter (default HTTP adapter, Net::HTTP)
lib/smartbill/sdk/transport.rb        # Transport module: build_auth, build_request, parse_envelope, handle_response + constants
lib/smartbill/sdk/transport/request.rb        # Transport::Request struct
lib/smartbill/sdk/transport/rate_limiter.rb   # Transport::RateLimiter
lib/smartbill/sdk/client.rb           # Client (sync) + services wiring
lib/smartbill/sdk/types.rb                # Types (Dry::Types) + StrOrInt sum type
lib/smartbill/sdk/models.rb           # Models namespace + INFLECTOR
lib/smartbill/sdk/models/struct.rb             # Struct < Dry::Struct: snake_case<->camelCase, to_h, to_attributes, ValidationError translation
lib/smartbill/sdk/models/document_type.rb     # DocumentType (constants)
lib/smartbill/sdk/models/payment_type.rb      # PaymentType (constants)
lib/smartbill/sdk/models/discount_type.rb     # DiscountType (constants)
lib/smartbill/sdk/models/client.rb            # Client
lib/smartbill/sdk/models/product.rb           # Product
lib/smartbill/sdk/models/invoice_ref.rb       # InvoiceRef (series/seriesName alias)
lib/smartbill/sdk/models/invoice_payment.rb   # InvoicePayment
lib/smartbill/sdk/models/invoice.rb           # Invoice
lib/smartbill/sdk/models/storno_request.rb    # StornoRequest
lib/smartbill/sdk/models/estimate.rb          # Estimate
lib/smartbill/sdk/models/payment.rb           # Payment
lib/smartbill/sdk/models/email_document.rb    # EmailDocument
lib/smartbill/sdk/models/tax.rb               # Tax
lib/smartbill/sdk/models/series.rb            # Series
lib/smartbill/sdk/models/taxes_response.rb    # TaxesResponse
lib/smartbill/sdk/models/series_list_response.rb # SeriesListResponse
lib/smartbill/sdk/models/stock_product.rb     # StockProduct
lib/smartbill/sdk/models/stock_warehouse.rb   # StockWarehouse
lib/smartbill/sdk/models/stock_list.rb        # StockList
lib/smartbill/sdk/models/stocks_response.rb   # StocksResponse
lib/smartbill/sdk/models/base_response.rb     # BaseResponse
lib/smartbill/sdk/models/invoice_create_response.rb
lib/smartbill/sdk/models/storno_response.rb
lib/smartbill/sdk/models/payment_status_response.rb
lib/smartbill/sdk/models/proforma_invoices_response.rb
lib/smartbill/sdk/models/email_status.rb
lib/smartbill/sdk/models/email_response.rb
lib/smartbill/sdk/models/fiscal_receipt_response.rb
lib/smartbill/sdk/services.rb          # Services namespace + dump_model/parse helpers
lib/smartbill/sdk/services/base_service.rb        # BaseService
lib/smartbill/sdk/services/invoices_service.rb    # InvoicesService
lib/smartbill/sdk/services/estimates_service.rb   # EstimatesService
lib/smartbill/sdk/services/payments_service.rb    # PaymentsService
lib/smartbill/sdk/services/email_service.rb       # EmailService
lib/smartbill/sdk/services/configuration_service.rb # ConfigurationService (taxes + series)
lib/smartbill/sdk/services/stocks_service.rb      # StocksService
lib/smartbill/sdk/contracts.rb         # Contracts namespace (dry-validation)
lib/smartbill/sdk/contracts/base.rb             # Contracts::Base < Dry::Validation::Contract + DATE_REGEX + validate!
lib/smartbill/sdk/contracts/invoice_contract.rb
lib/smartbill/sdk/contracts/estimate_contract.rb
lib/smartbill/sdk/contracts/payment_contract.rb
lib/smartbill/sdk/contracts/email_contract.rb
lib/smartbill/sdk/contracts/storno_contract.rb
lib/smartbill/sdk/contracts/invoice_payment_contract.rb
lib/smartbill/sdk/contracts/invoice_ref_contract.rb
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
*   **Autoloading**: Zeitwerk, one file per constant. To add a new class
    `Smartbill::Sdk::Foo::Bar`, create `lib/smartbill/sdk/foo/bar.rb`
    defining `class Bar` (and a `lib/smartbill/sdk/foo.rb` namespace file
    `module Foo; end` if the directory is new). Do **not** add
    `require_relative` for SDK-internal constants — let Zeitwerk resolve
    them. Only `require` stdlib/gems (`base64`, `json`, `net/http`, `uri`,
    `zeitwerk`) at the top of files that use them. If a file basename does
    not camelcase to the desired constant (e.g. `api_error.rb` → `APIError`,
    `version.rb` → `VERSION`), add an entry to `loader.inflector.inflect`
    in `lib/smartbill/sdk.rb`.
*   **Style**: 2-space indent, double-quote strings (enforced by RuboCop).
*   **Models**: subclass `Smartbill::Sdk::Models::Struct` (a `Dry::Struct`)
    and declare attributes with the dry-struct `attribute` DSL using types
    from `Smartbill::Sdk::Types` (e.g. `attribute :company_vat_code,
    Types::Strict::String`; `attribute :price, Types::Coercible::Float.optional.default(nil)`;
    `attribute :products, Types::Array.of(Product).default([].freeze)`).
    The base `Struct` handles: snake_case/camelCase input key normalization
    (`transform_keys` + `Dry::Inflector`), camelCase output via `#to_h`
    (nils omitted by default), recursive nested serialization, and
    `Dry::Struct::Error` → `ValidationError` translation. Mixed string/int
    fields use `Types::StrOrInt`. Unknown input keys are **ignored** (not
    preserved) — permissive parsing without re-emission. Use `#to_attributes`
    for the snake_case hash (with nils, nested structs → hashes) fed to
    contracts.
*   **Enums**: plain modules of string/int constants (`PaymentType::CHITANTA`
    == `"Chitanta"`). Pass the constant; it is stored/serialized as-is.
*   **Validation**: each request model has a `Smartbill::Sdk::Contracts::*Contract`
    (`< Contracts::Base < Dry::Validation::Contract`). The contract's `params`
    block declares only the fields with semantic rules (dates via
    `DATE_REGEX`, enum membership via `included_in?`, ranges, nested hashes);
    unknown keys are ignored by dry-validation. Services call
    `validate(struct, Contracts::XContract)` before sending, which runs
    `Contract.validate!(struct)` → `contract.new.call(struct.to_attributes)`
    and raises `ValidationError` with aggregated `path text` messages on
    failure. To add a rule, edit the contract's `params` block — do **not**
    re-declare every field, only the ones you validate.
*   **Services**: each service builds a `Transport::Request` via
    `Transport.build_request(...)` and parses the response with
    `Services.parse(payload, ModelClass)`. Services get the client (executor)
    injected; they call `@client.execute(request, binary: ...)`. Request-taking
    methods (`invoices.create`, `invoices.reverse`, `estimates.create`,
    `payments.create`, `email.send`) call `validate(model, Contracts::XContract)`
    **before** building the request so invalid input never hits the network.
*   **Errors**: raise `Smartbill::Sdk::Error` subclasses (one per file under
    `lib/smartbill/sdk/`); never bare `RuntimeError`. `Transport.handle_response`
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
*   **Runtime dependencies**: `base64` (no longer a default gem in Ruby
    3.4+), `zeitwerk` (autoloader), `dry-struct` + `dry-types` +
    `dry-inflector` (models) and `dry-validation` (request contracts). All
    are declared in the gemspec.
*   **Port origin**: this codebase was ported from the Python
    `smartbill-rest-sdk`; behavior, models and endpoint coverage match.
*   **Agent skills**: `skills/` ships three pi `SKILL.md` files
    (`smartbill-invoices`, `smartbill-payments`, `smartbill-email`) that
    teach coding agents how to use the SDK, with Ruby code snippets.
*   No other context files (`.cursorrules`, `CLAUDE.md`, etc.) exist.
