# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # The +status+ block of an {EmailResponse}.
      class EmailStatus < Model
        field :code
        field :message
      end
    end
  end
end
