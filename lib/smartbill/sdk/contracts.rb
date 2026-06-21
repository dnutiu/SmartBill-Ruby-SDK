# frozen_string_literal: true

require "dry-validation"

module Smartbill
  module Sdk
    # dry-validation contracts for SmartBill request models.
    #
    # Each request model has a {Models::Struct} (shape + coercion + required
    # presence) and a {Contracts::Contract} (semantic rules: date formats,
    # enum membership, numeric ranges). Services validate a struct against
    # its contract before sending and raise {ValidationError} on failure.
    #
    # Each contract lives in its own file (e.g. `contracts/invoice_contract.rb`
    # defines `InvoiceContract`) and is autoloaded by Zeitwerk.
    module Contracts
    end
  end
end
