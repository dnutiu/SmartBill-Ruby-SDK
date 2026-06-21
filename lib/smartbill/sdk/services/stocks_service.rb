# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
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
