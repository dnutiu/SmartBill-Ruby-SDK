# frozen_string_literal: true

require "test_helper"

# Tests for the dry-validation contracts (semantic rules on request models).
module Smartbill
  class TestContracts < Minitest::Test
    include SmartbillTest

    Models = Smartbill::Sdk::Models
    Contracts = Smartbill::Sdk::Contracts

    def test_invoice_contract_accepts_valid_invoice
      inv = Models::Invoice.new(
        company_vat_code: "RO12345678",
        issue_date: "2024-05-01",
        due_date: "2024-05-15",
        precision: 2,
        payment: Models::InvoicePayment.new(value: 50, type: "Card")
      )
      assert_same inv, Contracts::InvoiceContract.validate!(inv)
    end

    def test_invoice_contract_rejects_bad_dates
      inv = Models::Invoice.new(company_vat_code: "RO1", issue_date: "2024-5-1", due_date: "not-a-date")
      err = assert_raises(Smartbill::Sdk::ValidationError) { Contracts::InvoiceContract.validate!(inv) }
      assert_match(/issue_date/, err.message)
      assert_match(/due_date/, err.message)
    end

    def test_invoice_contract_rejects_negative_precision
      inv = Models::Invoice.new(company_vat_code: "RO1", precision: -1)
      assert_raises(Smartbill::Sdk::ValidationError) { Contracts::InvoiceContract.validate!(inv) }
    end

    def test_invoice_contract_rejects_invalid_nested_payment
      inv = Models::Invoice.new(
        company_vat_code: "RO1",
        payment: Models::InvoicePayment.new(value: -5, type: "Card")
      )
      err = assert_raises(Smartbill::Sdk::ValidationError) { Contracts::InvoiceContract.validate!(inv) }
      assert_match(/payment\.value/, err.message)
    end

    def test_payment_contract_validates_type_enum
      valid = Models::Payment.new(company_vat_code: "RO1", value: 10, type: "Ordin plata")
      assert_same valid, Contracts::PaymentContract.validate!(valid)

      invalid = Models::Payment.new(company_vat_code: "RO1", value: 10, type: "Cash money")
      err = assert_raises(Smartbill::Sdk::ValidationError) { Contracts::PaymentContract.validate!(invalid) }
      assert_match(/type/, err.message)
    end

    def test_payment_contract_rejects_non_positive_value
      inv = Models::Payment.new(company_vat_code: "RO1", value: -10, type: "Bon")
      assert_raises(Smartbill::Sdk::ValidationError) { Contracts::PaymentContract.validate!(inv) }
    end

    def test_email_contract_validates_document_type
      valid = Models::EmailDocument.new(
        company_vat_code: "RO1", series_name: "FCT", number: "0040",
        type: "factura", to: "client@example.ro"
      )
      assert_same valid, Contracts::EmailContract.validate!(valid)

      invalid = Models::EmailDocument.new(
        company_vat_code: "RO1", series_name: "FCT", number: "0040", type: "receipt"
      )
      err = assert_raises(Smartbill::Sdk::ValidationError) { Contracts::EmailContract.validate!(invalid) }
      assert_match(/type/, err.message)
    end

    def test_email_contract_validates_recipient_format
      invalid = Models::EmailDocument.new(
        company_vat_code: "RO1", series_name: "FCT", number: "0040", to: "not-an-email"
      )
      err = assert_raises(Smartbill::Sdk::ValidationError) { Contracts::EmailContract.validate!(invalid) }
      assert_match(/to/, err.message)
    end

    def test_storno_contract_accepts_valid
      s = Models::StornoRequest.new(company_vat_code: "RO1", series_name: "FCT", number: "0040",
                                    issue_date: "2024-05-01")
      assert_same s, Contracts::StornoContract.validate!(s)
    end

    def test_storno_contract_rejects_bad_date
      s = Models::StornoRequest.new(company_vat_code: "RO1", series_name: "FCT", number: "0040",
                                    issue_date: "bad")
      assert_raises(Smartbill::Sdk::ValidationError) { Contracts::StornoContract.validate!(s) }
    end

    def test_service_raises_validation_error_before_send
      # A payment with an invalid type never reaches the network.
      stub_request(:post, "#{BASE}payment").to_return(
        status: 200, body: JSON.generate(envelope("sbcResponse", number: "1", series: "CHT")),
        headers: { "Content-Type" => "application/json" }
      )
      c = make_client
      bad = Models::Payment.new(company_vat_code: "RO1", value: 10, type: "Nonsense")
      assert_raises(Smartbill::Sdk::ValidationError) { c.payments.create(bad) }
      assert_requested :post, "#{BASE}payment", times: 0
      c.close
    end
  end
end
