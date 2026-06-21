## [Unreleased]

## [1.0.0] - 2026-06-21

Ruby port of the Python `smartbill-rest-sdk` (v1.0.x).

- Synchronous `Smartbill::Sdk::Client` backed by stdlib `Net::HTTP`.
- Typed request/response models (snake_case Ruby attrs ↔ camelCase JSON)
  for invoices, proformas (estimates), payments, fiscal receipts, e-mail,
  taxes, series and stocks.
- Envelope unwrapping and a full error hierarchy (`Error`, `AuthError`,
  `RateLimitError`, `APIError`, `TransportError`, `ValidationError`).
- Optional client-side `RateLimiter` (30 calls / 10s).
- WebMock-based test suite (60 tests) and runnable examples.

## [0.1.0] - 2026-06-21

- Initial scaffold (bundle gem).
