module Codebreaker
  class Player
    include Validation

    attr_reader :name
    attr_accessor :errors_store

    LENGTH_RANGE = 3..20

    def assign_name(name)
      @errors_store = []
      return @name = name if validate_name(name)

      @errors_store << I18n.t(:when_wrong_name, min: LENGTH_RANGE.first, max: LENGTH_RANGE.last)
    end

    def valid?
      @errors_store.empty?
    end

    private

    def validate_name(name)
      return unless validate_presence?(name)

      valid_name?(name, LENGTH_RANGE)
    end
  end
end
