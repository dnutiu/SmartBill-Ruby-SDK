# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +POST /document/send+ (+Response.status+).
      class EmailResponse < Struct
        attribute :status, EmailStatus.optional.default(nil)
      end
    end
  end
end
