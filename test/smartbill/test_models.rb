# frozen_string_literal: true

require "test_helper"

# Tests for model aliasing, enums and validation.
module Smartbill
  class TestModels < Minitest::Test
    include SmartbillTest

    Models = Smartbill::Sdk::Models

    def test_invoice_aliasing_round_trip
      inv = Models::Invoice.new(
        company_vat_code: "RO12345678",
        client: Models::Client.new(name: "Intelligent IT", vat_code: "RO123", save_to_db: false),
        is_draft: false,
        series_name: "FCT",
        precision: 2,
        products: [
          Models::Product.new(name: "P1", measuring_unit_name: "buc", currency: "RON",
                              quantity: 2, price: 10, is_tax_included: true,
                              tax_name: "Redusa", tax_percentage: 9)
        ]
      )
      dumped = inv.to_h
      assert_equal "RO12345678", dumped["companyVatCode"]
      assert_equal "RO123", dumped["client"]["vatCode"]
      assert_equal "buc", dumped["products"][0]["measuringUnitName"]
      assert dumped["products"][0]["isTaxIncluded"]

      # Round-trip back.
      again = Models::Invoice.new(dumped)
      assert_equal "RO12345678", again.company_vat_code
      assert_equal "RO123", again.client.vat_code
      assert_equal "buc", again.products.first.measuring_unit_name
    end

    def test_product_discount_fields_optional
      p = Models::Product.new(name: "Discount", is_discount: true, number_of_items: 2,
                              measuring_unit_name: "buc", currency: "RON",
                              discount_type: Models::DiscountType::PROCENTUAL, discount_percentage: 10)
      dumped = p.to_h
      assert dumped["isDiscount"]
      assert_equal 2, dumped["discountType"]
      assert_equal 10, dumped["discountPercentage"]
    end

    def test_payment_enum_serializes_to_value
      pay = Models::Payment.new(company_vat_code: "RO1", value: 100, type: Models::PaymentType::ORDIN_PLATA)
      assert_equal "Ordin plata", pay.to_h["type"]
    end

    def test_payment_accepts_plain_string_type
      pay = Models::Payment.new(company_vat_code: "RO1", value: 100, type: "Chitanta")
      assert_equal "Chitanta", pay.type
    end

    def test_invoice_payment_required_fields
      ip = Models::InvoicePayment.new(value: 50, type: "Card")
      assert_equal({ "value" => 50, "type" => "Card" }, ip.to_h)
    end

    def test_invoice_ref_aliasing
      ref = Models::InvoiceRef.new(series_name: "FCT", number: "14")
      assert_equal({ "seriesName" => "FCT", "number" => "14" }, ref.to_h)

      # The GET /estimate/invoices response uses "series" rather than "seriesName".
      parsed = Models::InvoiceRef.new({ "series" => "FCT", "number" => "0028" })
      assert_equal "FCT", parsed.series_name
      assert_equal "0028", parsed.number
    end

    def test_estimate_basic
      est = Models::Estimate.new(company_vat_code: "RO1", client: Models::Client.new(name: "C"),
                                 series_name: "PFC", products: [])
      dumped = est.to_h
      assert_equal "RO1", dumped["companyVatCode"]
      assert_equal "C", dumped["client"]["name"]
    end

    def test_email_document_aliasing
      e = Models::EmailDocument.new(company_vat_code: "RO1", series_name: "FCT", number: "0040",
                                    type: Models::DocumentType::INVOICE, to: "a@b.ro")
      dumped = e.to_h
      assert_equal "factura", dumped["type"]
      assert_equal "a@b.ro", dumped["to"]
    end

    def test_storno_request
      s = Models::StornoRequest.new(company_vat_code: "RO1", series_name: "FFF", number: "0985")
      assert_equal({ "companyVatCode" => "RO1", "seriesName" => "FFF", "number" => "0985" }, s.to_h)
    end

    def test_invoice_requires_company_vat_code
      assert_raises(Smartbill::Sdk::ValidationError) do
        Models::Invoice.new(client: Models::Client.new(name: "x"))
      end
    end

    def test_client_requires_name
      assert_raises(Smartbill::Sdk::ValidationError) do
        Models::Client.new(vat_code: "RO1")
      end
    end

    # dry-struct ignores unknown input keys (permissive parsing — new API
    # fields don't break construction) but does not re-emit them on output.
    def test_extra_fields_are_ignored
      c = Models::Client.new(name: "X", "extraField" => 42)
      assert_equal "X", c.name
      refute c.to_h.key?("extraField")
    end
  end
end
