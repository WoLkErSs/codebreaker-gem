module Codebreaker
  class Player
    include Validation

    attr_reader :name
    attr_accessor :errors_store

    MAX_LENGTH = 20
    MIN_LENGTH = 3

    def assign_name(name)
      @errors_store = []
      return @name = name if validate_name(name)

      @errors_store << I18n.t(:when_wrong_name, min: MIN_LENGTH, max: MAX_LENGTH)
    end

    def valid?
      @errors_store.empty?
    end

    private

    def validate_name(name)
      return if validate_presence?(name)

      validate_length_in_range?(name, MIN_LENGTH, MAX_LENGTH)
    end
  end
end
