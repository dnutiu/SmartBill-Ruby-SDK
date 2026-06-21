# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
      # +/payment+ endpoints.
      class PaymentsService < BaseService
        def create(payment)
          parse(execute(build_request(
                          method: "POST", base_url: @client.base_url, path: "payment",
                          json_body: dump(payment), auth_header: @client.auth_header
                        )), Models::FiscalReceiptResponse)
        end

        # Delete a non-chitanta payment via +DELETE /payment/v2+.
        def delete_other(cif, payment_type:, payment_date: nil, payment_value: nil,
                         client_name: nil, client_cif: nil, invoice_series: nil,
                         invoice_number: nil)
          params = { "cif" => cif, "paymentType" => payment_type }
          params["paymentDate"]   = payment_date   unless payment_date.nil?
          params["paymentValue"]  = payment_value  unless payment_value.nil?
          params["clientName"]    = client_name    unless client_name.nil?
          params["clientCif"]     = client_cif     unless client_cif.nil?
          params["invoiceSeries"] = invoice_series unless invoice_series.nil?
          params["invoiceNumber"] = invoice_number unless invoice_number.nil?
          parse(execute(build_request(
                          method: "DELETE", base_url: @client.base_url, path: "payment/v2",
                          params: params, auth_header: @client.auth_header
                        )), Models::BaseResponse)
        end

        def delete_chitanta(cif, series_name, number)
          parse(execute(build_request(
                          method: "DELETE", base_url: @client.base_url, path: "payment/chitanta",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::BaseResponse)
        end

        def fiscal_receipt_text(cif, id)
          parse(execute(build_request(
                          method: "GET", base_url: @client.base_url, path: "payment/text",
                          params: { "cif" => cif, "id" => id }, auth_header: @client.auth_header
                        )), Models::FiscalReceiptResponse)
        end
      end
    end
  end
end
