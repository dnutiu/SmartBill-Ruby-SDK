# frozen_string_literal: true

module Smartbill
  module Sdk
    module Services
      # Base class for all services.
      class BaseService
        def initialize(client)
          @client = client
        end

        private

        # Run +contract+.validate! on +struct+, raising {ValidationError}
        # on failure. No-op contract-wise if +contract+ is nil.
        def validate(struct, contract)
          contract.validate!(struct)
          struct
        end

        def build_request(...)
          Transport.build_request(...)
        end

        def execute(request, binary: false)
          @client.execute(request, binary: binary)
        end

        def dump(model, envelope_key: nil)
          Services.dump_model(model, envelope_key: envelope_key)
        end

        def parse(payload, model_class)
          Services.parse(payload, model_class)
        end
      end
    end
  end
end
