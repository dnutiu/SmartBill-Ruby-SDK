# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Response for +POST /document/send+ (+Response.status+).
      class EmailResponse < Model
        field :status, type: EmailStatus
      end
    end
  end
end
