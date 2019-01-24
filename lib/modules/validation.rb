module Codebreaker
  module Validation
    def validate_in_range?(argument, range)
      range.include? argument
    end

    def valid_name?(name, range)
      validate_in_range?(name.length, range)
    end

    def valid_digits?(digits, range)
      digits.chars.map(&:to_i).each do |digit|
        return unless validate_in_range?(digit, range)
      end
    end

    def validate_presence?(entity)
      !entity.empty?
    end

    def validate_match(entity)
      entity.to_i.to_s == entity
    end

    def validate_length(entity, set_length)
      entity.length == set_length
    end
  end
end
