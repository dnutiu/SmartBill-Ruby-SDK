# frozen_string_literal: true

require_relative "transport"
require_relative "models"

module Smartbill
  module Sdk
    # Per-resource endpoint logic.
    #
    # Each service builds a {Transport::Request} for an endpoint and parses
    # the response into a model. Services are instantiated by {Client} with a
    # reference to the client (the "executor") which provides +base_url+,
    # +auth_header+ and +#execute+.
    module Services
      # Serialize a model, optionally wrapping it in an envelope.
      def self.dump_model(model, envelope_key: nil)
        data = model.to_h
        envelope_key ? { envelope_key => data } : data
      end

      # Parse a payload into a model instance.
      def self.parse(payload, model_class)
        return model_class.new if payload.nil?
        return model_class.new(payload) if payload.is_a?(Hash)

        model_class.new(message: payload.to_s)
      end

      # Base class for all services.
      class BaseService
        def initialize(client)
          @client = client
        end

        private

        def build_request(...)
          Transport.build_request(...)
        end

        def execute(request, binary: false)
          @client.execute(request, binary: binary)
        end

        def dump(model, envelope_key: nil)
          Services.dump_model(model, envelope_key: envelope_key)
        end

        def parse(payload, model_class)
          Services.parse(payload, model_class)
        end
      end

      # +/invoice+ endpoints.
      class InvoicesService < BaseService
        def create(invoice)
          parse(execute(build_request(
                          method: "POST", base_url: @client.base_url, path: "invoice",
                          json_body: dump(invoice), auth_header: @client.auth_header
                        )), Models::InvoiceCreateResponse)
        end

        def delete(cif, series_name, number)
          parse(execute(build_request(
                          method: "DELETE", base_url: @client.base_url, path: "invoice",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::BaseResponse)
        end

        def reverse(storno)
          parse(execute(build_request(
                          method: "POST", base_url: @client.base_url, path: "invoice/reverse",
                          json_body: dump(storno), auth_header: @client.auth_header
                        )), Models::StornoResponse)
        end

        def cancel(cif, series_name, number)
          cancel_restore("cancel", cif, series_name, number)
        end

        def restore(cif, series_name, number)
          cancel_restore("restore", cif, series_name, number)
        end

        def payment_status(cif, series_name, number)
          parse(execute(build_request(
                          method: "GET", base_url: @client.base_url, path: "invoice/paymentstatus",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::PaymentStatusResponse)
        end

        # Returns the raw PDF body as a binary String.
        def pdf(cif, series_name, number)
          execute(build_request(
                    method: "GET", base_url: @client.base_url, path: "invoice/pdf",
                    params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                    accept: "application/octet-stream", auth_header: @client.auth_header
                  ), binary: true)
        end

        private

        def cancel_restore(op, cif, series_name, number)
          parse(execute(build_request(
                          method: "PUT", base_url: @client.base_url, path: "invoice/#{op}",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::BaseResponse)
        end
      end

      # +/estimate+ endpoints.
      class EstimatesService < BaseService
        def create(estimate)
          parse(execute(build_request(
                          method: "POST", base_url: @client.base_url, path: "estimate",
                          json_body: dump(estimate), auth_header: @client.auth_header
                        )), Models::InvoiceCreateResponse)
        end

        def delete(cif, series_name, number)
          parse(execute(build_request(
                          method: "DELETE", base_url: @client.base_url, path: "estimate",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::BaseResponse)
        end

        def cancel(cif, series_name, number)
          cancel_restore("cancel", cif, series_name, number)
        end

        def restore(cif, series_name, number)
          cancel_restore("restore", cif, series_name, number)
        end

        def pdf(cif, series_name, number)
          execute(build_request(
                    method: "GET", base_url: @client.base_url, path: "estimate/pdf",
                    params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                    accept: "application/octet-stream", auth_header: @client.auth_header
                  ), binary: true)
        end

        def invoices_status(cif, series_name, number)
          parse(execute(build_request(
                          method: "GET", base_url: @client.base_url, path: "estimate/invoices",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::ProformaInvoicesResponse)
        end

        private

        def cancel_restore(op, cif, series_name, number)
          parse(execute(build_request(
                          method: "PUT", base_url: @client.base_url, path: "estimate/#{op}",
                          params: { "cif" => cif, "seriesName" => series_name, "number" => number },
                          auth_header: @client.auth_header
                        )), Models::BaseResponse)
        end
      end

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

      # +/document/send+ endpoint.
      class EmailService < BaseService
        def send(email)
          parse(execute(build_request(
                          method: "POST", base_url: @client.base_url, path: "document/send",
                          json_body: dump(email), auth_header: @client.auth_header
                        )), Models::EmailResponse)
        end
      end

      # +/tax+ and +/series+ endpoints.
      #
      # Note: on a {Client}, both +client.taxes+ and +client.series+ are the
      # same +ConfigurationService+ instance.
      class ConfigurationService < BaseService
        def taxes(cif)
          parse(execute(build_request(
                          method: "GET", base_url: @client.base_url, path: "tax",
                          params: { "cif" => cif }, auth_header: @client.auth_header
                        )), Models::TaxesResponse)
        end

        def series(cif, type: nil)
          params = { "cif" => cif }
          params["type"] = type unless type.nil?
          parse(execute(build_request(
                          method: "GET", base_url: @client.base_url, path: "series",
                          params: params, auth_header: @client.auth_header
                        )), Models::SeriesListResponse)
        end
      end

      # +/stocks+ endpoint.
      class StocksService < BaseService
        def get(cif, date, warehouse_name: nil, product_name: nil, product_code: nil)
          params = { "cif" => cif, "date" => date }
          params["warehouseName"] = warehouse_name unless warehouse_name.nil?
          params["productName"]   = product_name   unless product_name.nil?
          params["productCode"]   = product_code   unless product_code.nil?
          parse(execute(build_request(
                          method: "GET", base_url: @client.base_url, path: "stocks",
                          params: params, auth_header: @client.auth_header
                        )), Models::StocksResponse)
        end
      end
    end
  end
end
