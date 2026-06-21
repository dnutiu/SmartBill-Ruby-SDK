# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
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
    end
  end
end
