# frozen_string_literal: true

module Smartbill
  module Sdk
    # Per-resource endpoint logic.
    #
    # Each service builds a {Transport::Request} for an endpoint and parses
    # the response into a model. Services are instantiated by {Client} with a
    # reference to the client (the "executor") which provides +base_url+,
    # +auth_header+ and +#execute+.
    #
    # Each service lives in its own file (e.g. `services/invoices_service.rb`
    # defines `InvoicesService`) and is autoloaded by Zeitwerk.
    module Services
      # Serialize a model, optionally wrapping it in an envelope.
      def self.dump_model(model, envelope_key: nil)
        data = model.to_h
        envelope_key ? { envelope_key => data } : data
      end

      # Parse a payload into a model instance.
      def self.parse(payload, model_class)
        return model_class.new if payload.nil?
        return model_class.new(payload) if payload.is_a?(Hash)

        model_class.new(message: payload.to_s)
      end
    end
  end
end
