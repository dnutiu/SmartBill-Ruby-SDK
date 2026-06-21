# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
      # +/estimate+ endpoints.
      class EstimatesService < BaseService
        def create(estimate)
          validate(estimate, Contracts::EstimateContract)
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
    end
  end
end
