# frozen_string_literal: true

require "test_helper"
require "json"

# Endpoint tests for PaymentsService via WebMock.
module Smartbill
  class TestPayments < Minitest::Test
    include SmartbillTest

    Models = Smartbill::Sdk::Models

    def setup
      WebMock.reset!
    end

    def test_payment_create_general_sync
      stub = stub_request(:post, "#{BASE}payment")
             .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", number: "0030", series: "CHT")),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      pay = Models::Payment.new(company_vat_code: "RO1", client: Models::Client.new(name: "X"), value: 14,
                                type: Models::PaymentType::ORDIN_PLATA, is_cash: false,
                                invoices_list: [Models::InvoiceRef.new(series_name: "FCT", number: "14")])
      r = c.payments.create(pay)
      assert_equal "CHT", r.series
      payload = JSON.parse(last_request.body)
      assert_equal "RO1", payload["companyVatCode"]
      assert_equal "Ordin plata", payload["type"]
      assert_equal "FCT", payload["invoicesList"][0]["seriesName"]
      assert_requested stub
      c.close
    end

    def test_payment_create_chitanta
      stub_request(:post, "#{BASE}payment")
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", number: "1", series: "CHT")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      pay = Models::Payment.new(company_vat_code: "RO1", client: Models::Client.new(name: "X"),
                                value: 14, type: Models::PaymentType::CHITANTA, series_name: "CHT")
      r = c.payments.create(pay)
      assert_equal "1", r.number
      c.close
    end

    def test_payment_delete_other_by_invoice
      stub = stub_request(:delete, "#{BASE}payment/v2")
             .with(query: { "cif" => "RO1", "paymentType" => "Ordin plata",
                            "invoiceSeries" => "FCT", "invoiceNumber" => "0024" })
             .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      c.payments.delete_other("RO1", payment_type: "Ordin plata",
                                     invoice_series: "FCT", invoice_number: "0024")
      p = query_of(last_request)
      assert_equal "RO1", p["cif"]
      assert_equal "Ordin plata", p["paymentType"]
      assert_equal "FCT", p["invoiceSeries"]
      assert_equal "0024", p["invoiceNumber"]
      # unused optional params should not be present
      refute p.key?("paymentDate")
      assert_requested stub
      c.close
    end

    def test_payment_delete_other_by_params
      stub_request(:delete, "#{BASE}payment/v2")
        .with(query: { "cif" => "RO1", "paymentType" => "Card",
                       "paymentDate" => "2021-02-15", "paymentValue" => "20",
                       "clientName" => "Intelligent IT", "clientCif" => "RO12345678" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      c.payments.delete_other("RO1", payment_type: "Card",
                                     payment_date: "2021-02-15", payment_value: 20,
                                     client_name: "Intelligent IT", client_cif: "RO12345678")
      p = query_of(last_request)
      assert_equal "2021-02-15", p["paymentDate"]
      assert_equal "20", p["paymentValue"]
      assert_equal "Intelligent IT", p["clientName"]
      assert_equal "RO12345678", p["clientCif"]
      refute p.key?("invoiceSeries")
      c.close
    end

    def test_payment_delete_chitanta_sync
      stub_request(:delete, "#{BASE}payment/chitanta")
        .with(query: { "cif" => "RO1", "seriesName" => "CHT", "number" => "0115" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      c.payments.delete_chitanta("RO1", "CHT", "0115")
      p = query_of(last_request)
      assert_equal "CHT", p["seriesName"]
      assert_equal "0115", p["number"]
      c.close
    end

    def test_payment_fiscal_receipt_text_sync
      stub_request(:get, "#{BASE}payment/text")
        .with(query: { "cif" => "RO1", "id" => "12345" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "UCwxLF9f", number: "", series: "")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.payments.fiscal_receipt_text("RO1", "12345")
      assert_equal "UCwxLF9f", r.message
      c.close
    end

    def test_payment_bon_fiscal_received_fields_serialized
      stub_request(:post, "#{BASE}payment")
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", id: "12345", number: "12")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      pay = Models::Payment.new(company_vat_code: "RO1", value: 260, type: "Bon", number: "",
                                return_fiscal_printer_text: true, use_stock: false,
                                received_cash: 200, received_card: 60)
      resp = c.payments.create(pay)
      assert_equal "12345", resp.id
      assert_equal "12", resp.number
      payload = JSON.parse(last_request.body)
      assert_equal 200, payload["receivedCash"]
      assert_equal 60, payload["receivedCard"]
      assert payload["returnFiscalPrinterText"]
      c.close
    end
  end
end
