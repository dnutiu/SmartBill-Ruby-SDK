# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # The +status+ block of an {EmailResponse}.
      class EmailStatus < Struct
        attribute :code, Types::StrOrInt.optional.default(nil)
        attribute :message, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
