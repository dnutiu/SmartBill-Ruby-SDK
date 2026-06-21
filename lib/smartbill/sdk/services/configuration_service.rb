# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
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
    end
  end
end
