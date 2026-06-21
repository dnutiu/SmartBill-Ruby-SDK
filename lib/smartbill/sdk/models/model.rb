# frozen_string_literal: true

module Smartbill
  module Sdk
    module Models
      # Base class for every SmartBill request/response model.
      #
      # Models use snake_case Ruby attributes aliased to the camelCase JSON
      # field names used by the SmartBill API (e.g. +company_vat_code+ ↔
      # +companyVatCode+). Models are permissive — unknown fields passed
      # on construction are kept and re-emitted on serialization so new API
      # fields don't break parsing.
      #
      # Subclasses declare their fields with {.field}:
      #
      #   class MyThing < Model
      #     field :company_vat_code, required: true
      #     field :client, type: Client
      #     field :products, type: [Product], default: []
      #   end
      #
      # On input both snake_case and camelCase keys are accepted. Fields may
      # declare extra input aliases (e.g. +seriesName+ and +series+ both map
      # to +series_name+).
      class Model
        class << self
          # Map of field name (Symbol) => { json_key:, default:, type:, required: }.
          def fields
            @fields ||= {}
          end

          # Array of required field names.
          def required_fields
            @required_fields ||= []
          end

          # Declare an attribute.
          #
          # @param name [Symbol] snake_case attribute name.
          # @param json_key [String, nil] camelCase JSON key (defaults to
          #   the camelCased attribute name).
          # @param required [Boolean] whether the field must be present.
          # @param default [Object] default value when not provided.
          # @param type [Class, Array<Class>, nil] a Model subclass for
          #   nested objects, or +[ModelSubclass]+ for arrays of nested
          #   objects. Used to coerce Hash input into model instances.
          # @param input_keys [Array<String>] additional accepted input keys.
          def field(name, json_key: nil, required: false, default: nil, type: nil, input_keys: [])
            json_key ||= camelcase(name.to_s)
            fields[name] = {
              json_key: json_key,
              default: default,
              type: type,
              required: required,
              input_keys: Array(input_keys)
            }
            attr_accessor name

            required_fields << name if required
            # Invalidate the cached input map.
            @input_map = nil
            name
          end

          # Resolve an input key (String or Symbol) to a field name, or nil.
          def field_for_input(key)
            input_map[key.to_s]
          end

          # Parse a Hash (or already-typed value) into a model instance.
          def from_h(hash)
            return hash if hash.is_a?(self)

            new(hash || {})
          end

          protected

          def inherited(subclass)
            super
            subclass.instance_variable_set(:@fields, fields.dup)
            subclass.instance_variable_set(:@required_fields, required_fields.dup)
            subclass.instance_variable_set(:@input_map, nil)
          end

          private

          def input_map
            @input_map ||= begin
              map = {}
              fields.each do |name, opts|
                map[name.to_s] = name
                map[opts[:json_key]] = name
                opts[:input_keys].each { |k| map[k] = name }
              end
              map
            end
          end

          def camelcase(str)
            str.gsub(/_([a-z0-9])/) { Regexp.last_match(1).upcase }
          end
        end

        def initialize(attrs = {})
          @extra = {}
          apply_defaults
          attrs.each { |key, value| assign_input(key, value) }
          validate_required!
        end

        # Serialize to a Hash.
        #
        # @param exclude_none [Boolean] skip nil values (default true).
        # @param by_alias [Boolean] use camelCase JSON keys (default true).
        def to_h(exclude_none: true, by_alias: true)
          result = {}
          self.class.fields.each do |name, opts|
            value = public_send(name)
            next if exclude_none && value.nil?

            key = by_alias ? opts[:json_key] : name.to_s
            result[key] = serialize_value(value, exclude_none, by_alias)
          end
          @extra.each { |k, v| result[k] = serialize_value(v, exclude_none, by_alias) }
          result
        end

        def to_json(*)
          to_h.to_json(*)
        end

        def ==(other)
          other.is_a?(self.class) && to_h == other.to_h
        end

        def inspect
          "#<#{self.class.name} #{to_h.inspect}>"
        end

        private

        def apply_defaults
          self.class.fields.each do |name, opts|
            next if opts[:default].nil?

            public_send("#{name}=", opts[:default])
          end
        end

        def assign_input(key, value)
          fname = self.class.field_for_input(key)
          if fname
            public_send("#{fname}=", coerce(fname, value))
          else
            @extra[key.to_s] = value
          end
        end

        def coerce(fname, value)
          type = self.class.fields[fname][:type]
          return value if type.nil?

          if type.is_a?(Array)
            inner = type[0]
            return value.map { |e| coerce_single(inner, e) }
          end
          coerce_single(type, value)
        end

        def coerce_single(type, value)
          return value if value.is_a?(type)
          return type.new(value) if value.is_a?(Hash)

          value
        end

        def serialize_value(value, exclude_none, by_alias)
          if value.is_a?(Model)
            value.to_h(exclude_none: exclude_none, by_alias: by_alias)
          elsif value.is_a?(Array)
            value.map { |e| serialize_value(e, exclude_none, by_alias) }
          else
            value
          end
        end

        def validate_required!
          missing = self.class.required_fields.select { |name| public_send(name).nil? }
          return if missing.empty?

          raise ValidationError, "Missing required fields: #{missing.join(", ")}"
        end
      end
    end
  end
end
