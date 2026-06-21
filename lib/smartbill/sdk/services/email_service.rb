# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
      # +/document/send+ endpoint.
      class EmailService < BaseService
        def send(email)
          parse(execute(build_request(
                          method: "POST", base_url: @client.base_url, path: "document/send",
                          json_body: dump(email), auth_header: @client.auth_header
                        )), Models::EmailResponse)
        end
      end
    end
  end
end
