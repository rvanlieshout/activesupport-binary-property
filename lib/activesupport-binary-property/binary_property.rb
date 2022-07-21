module BinaryProperty
  extend ActiveSupport::Concern

  class NonUniqPropertyValueError < StandardError; end
  class ValueUsesMultipleBitsError < StandardError; end

  included do
    def self.has_binary_property(attribute, property_table, _prefix: false, _suffix: false)
      prefix = case _prefix
               when true then "#{attribute.to_s.singularize}_"
               when String then _prefix
               else ''
               end

      suffix = case _suffix
               when true then "_#{attribute.to_s.singularize}"
               when String then _suffix
               else ''
               end

      # validate property_table
      #
      # 1. Values schould be uniq
      raise NonUniqPropertyValueError if property_table.values.length != property_table.values.uniq.length
      # 2. Values should all be a single bit (e.g. 2, 4, 8, ..)
      raise ValueUsesMultipleBitsError if property_table.values.any? { |value| value.to_s(2).count('1') != 1 }

                                                                  # Examples using:
                                                                  #
                                                                  # has_binary_property :permission_grants, {
                                                                  #                       manage_contact_people: 2,
                                                                  #                       request_administrative_changes: 4,
                                                                  #                       request_technical_changes: 6
                                                                  #                     }

      singleton_class.instance_eval do
        define_method("#{attribute}") do                          # def self.permission_grants
          property_table                                          #   {
                                                                  #      manage_contact_people: 2,
                                                                  #      request_administrative_changes: 4,
                                                                  #      request_technical_changes: 6
                                                                  #    }
        end                                                       # end
      end

      define_method("#{attribute.to_s.singularize}_list") do      # def permission_grant_list
        current_value = send(attribute)                           #   current_value = permission_grants
        property_table                                            #   property_table
          .select do |_key, value|                                #     .select do |_key, value|
            (current_value & value) == value                      #       (current_value & value) == value
          end                                                     #     end
          .map do |key, _value|                                   #     .map do |key, _value|
            key                                                   #       key
          end                                                     #     end
      end                                                         # end

      define_method("#{attribute.to_s.singularize}?") do |value|  # def permission_grant?(value)
        current_value = send(attribute)                           #   current_value = permission_grants
        search_value = property_table[value]                      #   search_value = property_table[value]
                                                                  #
        (current_value & search_value) == search_value            #   (current_value & search_value) == search_value
      end                                                         # end

      property_table.each do |key, value|
        attribute_name = "#{prefix}#{key}#{suffix}"

        # This uses a boolean comparision
        #
        # Example:
        #
        # * permission_grants = 6
        # * key = manage_contact_people
        # * value = 2
        #
        # Query:
        #
        #     (permission_grants & :value) = :value
        #
        # is transformed into:
        #
        #    (6 & 2) = 2
        #
        # Is actually:
        #
        #     6: 0000 1010
        #     2: 0000 0010
        #        ---------
        #     &  0000 0010
        #
        # An AND (&) comparision will either only result in
        # our number (2) or none (0). It can only have one
        # bit set since we use a single bit as part of our
        # AND. The output is thus either our value or 0
        scope attribute_name, -> {                                # scope request_administrative_changes, -> {
          where(                                                  #   where(
            "(#{attribute} & :value) = :value",                   #     '(permission_grants & :value) = :value',
            value: value                                          #     value: 4
          )                                                       #   )
        }                                                         # }

        define_method("#{attribute_name}") do                     # def request_administrative_changes
          send("#{attribute.to_s.singularize}?", key)             #   permission_grant?(:request_administrative_changes)
        end                                                       # end

        define_method("#{attribute_name}?") do                    # def request_administrative_changes?
          send("#{attribute.to_s.singularize}?", key)             #   permission_grant?(:request_administrative_changes)
        end                                                       # end

        # An example about binary OR and XOR:
        #
        # Given:
        #
        # a = 0011 1100
        # b = 0000 1101
        #
        # Then:
        #
        # a | b	= 0011 1101 (OR: copies a bit if it exists in either operand)
        # a ^ b	= 0011 0001 (XOR copies the bit if it is set in one operand but not both)
        #
        define_method("#{attribute_name}=") do |enable|           # def request_administrative_changes=(enable)
          enable = false if enable.in?(['0', 0])                  #   enable = false if enable.in?(['0', 0])
                                                                  #
          if enable                                               #   if enable
            send("#{attribute}=", (send(attribute) || 0) | value) #     self.permission_grants = (permission_grants || 0) | 4
          elsif send("#{attribute_name}?")                        #   elsif request_administrative_changes?
            send("#{attribute}=", (send(attribute) || 0) ^ value) #     self.permission_grants = (permission_grants || 0) ^ 4
          end                                                     #   end
        end                                                       # end
      end
    end
  end
end
