=begin
#Cyber Trackr API

#Complete OpenAPI 3.1.1 specification for cyber.trackr.live API. This API provides access to DISA STIGs, SRGs, RMF controls, CCIs, and SCAP data.  ## DISA Cybersecurity Ecosystem Hierarchy  ``` NIST RMF Controls (high-level policy framework)     ↓ (decomposed into atomic, testable statements) CCIs (Control Correlation Identifiers - bridge policy to implementation)     ↓ (grouped by technology class into generic requirements)   SRGs (Security Requirements Guides - technology class \"what\" to do)     ↓ (implemented as vendor-specific \"how\" to do it) STIGs (Security Technical Implementation Guides - vendor/product specific)     ↓ (automated versions for scanning tools) SCAP (Security Content Automation Protocol documents) ```  ## Critical Relationships  - **RMF Controls** contain assessment procedures that reference **CCIs** - **CCIs** map back to **RMF Controls** and forward to **STIG/SRG requirements** - **SRGs** define generic technology requirements that **STIGs** implement specifically - **V-IDs** can appear in both SRG and corresponding STIG (same requirement, different specificity) - **SV-IDs** are XCCDF rule identifiers with revision tracking across document releases 

The version of the OpenAPI document: 1.0.0

Generated by: https://openapi-generator.tech
Generator version: 7.14.0

=end

require 'date'
require 'time'

module CyberTrackrClient
  # Complete RMF control details with CCI mappings
  class RmfControlDetail
    attr_accessor :number

    attr_accessor :title

    attr_accessor :family

    attr_accessor :baseline

    attr_accessor :statements

    attr_accessor :assessment_procedures

    class EnumAttributeValidator
      attr_reader :datatype
      attr_reader :allowable_values

      def initialize(datatype, allowable_values)
        @allowable_values = allowable_values.map do |value|
          case datatype.to_s
          when /Integer/i
            value.to_i
          when /Float/i
            value.to_f
          else
            value
          end
        end
      end

      def valid?(value)
        !value || allowable_values.include?(value)
      end
    end

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'number' => :'number',
        :'title' => :'title',
        :'family' => :'family',
        :'baseline' => :'baseline',
        :'statements' => :'statements',
        :'assessment_procedures' => :'assessment_procedures'
      }
    end

    # Returns attribute mapping this model knows about
    def self.acceptable_attribute_map
      attribute_map
    end

    # Returns all the JSON keys this model knows about
    def self.acceptable_attributes
      acceptable_attribute_map.values
    end

    # Attribute type mapping.
    def self.openapi_types
      {
        :'number' => :'String',
        :'title' => :'String',
        :'family' => :'String',
        :'baseline' => :'Array<String>',
        :'statements' => :'String',
        :'assessment_procedures' => :'Array<AssessmentProcedure>'
      }
    end

    # List of attributes with nullable: true
    def self.openapi_nullable
      Set.new([
      ])
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      if (!attributes.is_a?(Hash))
        fail ArgumentError, "The input argument (attributes) must be a hash in `CyberTrackrClient::RmfControlDetail` initialize method"
      end

      # check to see if the attribute exists and convert string to symbol for hash key
      acceptable_attribute_map = self.class.acceptable_attribute_map
      attributes = attributes.each_with_object({}) { |(k, v), h|
        if (!acceptable_attribute_map.key?(k.to_sym))
          fail ArgumentError, "`#{k}` is not a valid attribute in `CyberTrackrClient::RmfControlDetail`. Please check the name to make sure it's valid. List of attributes: " + acceptable_attribute_map.keys.inspect
        end
        h[k.to_sym] = v
      }

      if attributes.key?(:'number')
        self.number = attributes[:'number']
      else
        self.number = nil
      end

      if attributes.key?(:'title')
        self.title = attributes[:'title']
      else
        self.title = nil
      end

      if attributes.key?(:'family')
        self.family = attributes[:'family']
      else
        self.family = nil
      end

      if attributes.key?(:'baseline')
        if (value = attributes[:'baseline']).is_a?(Array)
          self.baseline = value
        end
      else
        self.baseline = nil
      end

      if attributes.key?(:'statements')
        self.statements = attributes[:'statements']
      else
        self.statements = nil
      end

      if attributes.key?(:'assessment_procedures')
        if (value = attributes[:'assessment_procedures']).is_a?(Array)
          self.assessment_procedures = value
        end
      else
        self.assessment_procedures = nil
      end
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      warn '[DEPRECATED] the `list_invalid_properties` method is obsolete'
      invalid_properties = Array.new
      if @number.nil?
        invalid_properties.push('invalid value for "number", number cannot be nil.')
      end

      pattern = Regexp.new(/^[A-Z]+-\d+$/)
      if @number !~ pattern
        invalid_properties.push("invalid value for \"number\", must conform to the pattern #{pattern}.")
      end

      if @title.nil?
        invalid_properties.push('invalid value for "title", title cannot be nil.')
      end

      if @title.to_s.length < 1
        invalid_properties.push('invalid value for "title", the character length must be greater than or equal to 1.')
      end

      if @family.nil?
        invalid_properties.push('invalid value for "family", family cannot be nil.')
      end

      if @family.to_s.length < 1
        invalid_properties.push('invalid value for "family", the character length must be greater than or equal to 1.')
      end

      if @baseline.nil?
        invalid_properties.push('invalid value for "baseline", baseline cannot be nil.')
      end

      if @baseline.length < 1
        invalid_properties.push('invalid value for "baseline", number of items must be greater than or equal to 1.')
      end

      if @statements.nil?
        invalid_properties.push('invalid value for "statements", statements cannot be nil.')
      end

      if @statements.to_s.length < 1
        invalid_properties.push('invalid value for "statements", the character length must be greater than or equal to 1.')
      end

      if @assessment_procedures.nil?
        invalid_properties.push('invalid value for "assessment_procedures", assessment_procedures cannot be nil.')
      end

      if @assessment_procedures.length < 1
        invalid_properties.push('invalid value for "assessment_procedures", number of items must be greater than or equal to 1.')
      end

      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      warn '[DEPRECATED] the `valid?` method is obsolete'
      return false if @number.nil?
      return false if @number !~ Regexp.new(/^[A-Z]+-\d+$/)
      return false if @title.nil?
      return false if @title.to_s.length < 1
      return false if @family.nil?
      return false if @family.to_s.length < 1
      return false if @baseline.nil?
      return false if @baseline.length < 1
      return false if @statements.nil?
      return false if @statements.to_s.length < 1
      return false if @assessment_procedures.nil?
      return false if @assessment_procedures.length < 1
      true
    end

    # Custom attribute writer method with validation
    # @param [Object] number Value to be assigned
    def number=(number)
      if number.nil?
        fail ArgumentError, 'number cannot be nil'
      end

      pattern = Regexp.new(/^[A-Z]+-\d+$/)
      if number !~ pattern
        fail ArgumentError, "invalid value for \"number\", must conform to the pattern #{pattern}."
      end

      @number = number
    end

    # Custom attribute writer method with validation
    # @param [Object] title Value to be assigned
    def title=(title)
      if title.nil?
        fail ArgumentError, 'title cannot be nil'
      end

      if title.to_s.length < 1
        fail ArgumentError, 'invalid value for "title", the character length must be greater than or equal to 1.'
      end

      @title = title
    end

    # Custom attribute writer method with validation
    # @param [Object] family Value to be assigned
    def family=(family)
      if family.nil?
        fail ArgumentError, 'family cannot be nil'
      end

      if family.to_s.length < 1
        fail ArgumentError, 'invalid value for "family", the character length must be greater than or equal to 1.'
      end

      @family = family
    end

    # Custom attribute writer method with validation
    # @param [Object] statements Value to be assigned
    def statements=(statements)
      if statements.nil?
        fail ArgumentError, 'statements cannot be nil'
      end

      if statements.to_s.length < 1
        fail ArgumentError, 'invalid value for "statements", the character length must be greater than or equal to 1.'
      end

      @statements = statements
    end

    # Custom attribute writer method with validation
    # @param [Object] assessment_procedures Value to be assigned
    def assessment_procedures=(assessment_procedures)
      if assessment_procedures.nil?
        fail ArgumentError, 'assessment_procedures cannot be nil'
      end

      if assessment_procedures.length < 1
        fail ArgumentError, 'invalid value for "assessment_procedures", number of items must be greater than or equal to 1.'
      end

      @assessment_procedures = assessment_procedures
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
          number == o.number &&
          title == o.title &&
          family == o.family &&
          baseline == o.baseline &&
          statements == o.statements &&
          assessment_procedures == o.assessment_procedures
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Integer] Hash code
    def hash
      [number, title, family, baseline, statements, assessment_procedures].hash
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def self.build_from_hash(attributes)
      return nil unless attributes.is_a?(Hash)
      attributes = attributes.transform_keys(&:to_sym)
      transformed_hash = {}
      openapi_types.each_pair do |key, type|
        if attributes.key?(attribute_map[key]) && attributes[attribute_map[key]].nil?
          transformed_hash["#{key}"] = nil
        elsif type =~ /\AArray<(.*)>/i
          # check to ensure the input is an array given that the attribute
          # is documented as an array but the input is not
          if attributes[attribute_map[key]].is_a?(Array)
            transformed_hash["#{key}"] = attributes[attribute_map[key]].map { |v| _deserialize($1, v) }
          end
        elsif !attributes[attribute_map[key]].nil?
          transformed_hash["#{key}"] = _deserialize(type, attributes[attribute_map[key]])
        end
      end
      new(transformed_hash)
    end

    # Deserializes the data based on type
    # @param string type Data type
    # @param string value Value to be deserialized
    # @return [Object] Deserialized data
    def self._deserialize(type, value)
      case type.to_sym
      when :Time
        Time.parse(value)
      when :Date
        Date.parse(value)
      when :String
        value.to_s
      when :Integer
        value.to_i
      when :Float
        value.to_f
      when :Boolean
        if value.to_s =~ /\A(true|t|yes|y|1)\z/i
          true
        else
          false
        end
      when :Object
        # generic object (usually a Hash), return directly
        value
      when /\AArray<(?<inner_type>.+)>\z/
        inner_type = Regexp.last_match[:inner_type]
        value.map { |v| _deserialize(inner_type, v) }
      when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
        k_type = Regexp.last_match[:k_type]
        v_type = Regexp.last_match[:v_type]
        {}.tap do |hash|
          value.each do |k, v|
            hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
          end
        end
      else # model
        # models (e.g. Pet) or oneOf
        klass = CyberTrackrClient.const_get(type)
        klass.respond_to?(:openapi_any_of) || klass.respond_to?(:openapi_one_of) ? klass.build(value) : klass.build_from_hash(value)
      end
    end

    # Returns the string representation of the object
    # @return [String] String presentation of the object
    def to_s
      to_hash.to_s
    end

    # to_body is an alias to to_hash (backward compatibility)
    # @return [Hash] Returns the object in the form of hash
    def to_body
      to_hash
    end

    # Returns the object in the form of hash
    # @return [Hash] Returns the object in the form of hash
    def to_hash
      hash = {}
      self.class.attribute_map.each_pair do |attr, param|
        value = self.send(attr)
        if value.nil?
          is_nullable = self.class.openapi_nullable.include?(attr)
          next if !is_nullable || (is_nullable && !instance_variable_defined?(:"@#{attr}"))
        end

        hash[param] = _to_hash(value)
      end
      hash
    end

    # Outputs non-array value in the form of hash
    # For object, use to_hash. Otherwise, just return the value
    # @param [Object] value Any valid value
    # @return [Hash] Returns the value in the form of hash
    def _to_hash(value)
      if value.is_a?(Array)
        value.compact.map { |v| _to_hash(v) }
      elsif value.is_a?(Hash)
        {}.tap do |hash|
          value.each { |k, v| hash[k] = _to_hash(v) }
        end
      elsif value.respond_to? :to_hash
        value.to_hash
      else
        value
      end
    end

  end

end
