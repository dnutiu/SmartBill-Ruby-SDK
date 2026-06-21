# frozen_string_literal: true

require "dry-struct"

module Smartbill
  module Sdk
    module Models
      # Base class for every SmartBill request/response model.
      #
      # A thin adapter over `Dry::Struct` that gives the SDK:
      #
      # * snake_case Ruby attributes aliased to camelCase JSON keys — both
      #   `company_vat_code` and `"companyVatCode"` are accepted on input,
      #   and {#to_h} emits camelCase keys (matching the SmartBill API);
      # * type coercion of scalars and nested structs / arrays of structs;
      # * required-attribute presence (a missing required attribute raises
      #   {ValidationError}, translated from `Dry::Struct::Error`);
      # * permissive parsing — unknown input keys are ignored so new API
      #   fields don't break parsing;
      # * {#to_attributes} returning the snake_case hash (with nils) used by
      #   the dry-validation contracts.
      #
      # Subclasses declare attributes with the dry-struct `attribute` DSL:
      #
      #   class MyThing < Struct
      #     attribute :company_vat_code, Types::Strict::String
      #     attribute :client, Client.optional.default(nil)
      #     attribute :products, Types::Array.of(Product).default([].freeze)
      #   end
      class Struct < Dry::Struct
        # Accept snake_case and camelCase input keys (String or Symbol),
        # normalising to the snake_case Symbol keys dry-struct expects.
        transform_keys { |key| INFLECTOR.underscore(key.to_s).to_sym }

        class << self
          # Construct a struct, translating dry-struct type errors (e.g. a
          # missing required attribute) into the SDK's {ValidationError}.
          def new(attrs = Dry::Core::Constants::EMPTY_HASH, &)
            super
          rescue Dry::Struct::Error => e
            raise ValidationError, e.message
          end
        end

        # Serialize to a camelCase-keyed Hash matching the SmartBill API,
        # omitting nil values by default. Nested structs and arrays of
        # structs are serialized recursively.
        #
        # @param exclude_none [Boolean] skip nil values (default true).
        def to_h(exclude_none: true)
          self.class.schema.keys.each_with_object({}) do |key, hash|
            value = public_send(key.name)
            next if exclude_none && value.nil?

            hash[camelize_key(key.name)] = serialize_value(value, exclude_none)
          end
        end

        def to_json(*)
          to_h.to_json(*)
        end

        # Return a snake_case Symbol-keyed Hash (including nils) reflecting
        # the Ruby attributes, with nested structs and arrays of structs
        # recursively converted to hashes. Used as input to the validation
        # contracts (which operate on hashes, not struct instances).
        def to_attributes
          self.class.schema.keys.to_h do |key|
            [key.name, attribute_value(public_send(key.name))]
          end
        end

        private

        def attribute_value(value)
          if value.is_a?(Struct)
            value.to_attributes
          elsif value.is_a?(Array)
            value.map { |element| attribute_value(element) }
          else
            value
          end
        end

        def camelize_key(name)
          camelized = INFLECTOR.camelize(name.to_s)
          "#{camelized[0].downcase}#{camelized[1..]}"
        end

        def serialize_value(value, exclude_none)
          if value.is_a?(Struct)
            value.to_h(exclude_none: exclude_none)
          elsif value.is_a?(Array)
            value.map { |element| serialize_value(element, exclude_none) }
          else
            value
          end
        end
      end
    end
  end
end
