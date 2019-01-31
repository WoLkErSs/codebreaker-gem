module Codebreaker
  class Game
    include Validation

    INCREMENT = 1
    AMOUNT_DIGITS = 4
    POSITIVE_DIGIT = '+'.freeze
    NEGATIVE_DIGIT = '-'.freeze
    DIFFICULTIES = {
      easy: { attempts: 15, hints: 2, difficulty: 'easy' },
      hard: { attempts: 10, hints: 2, difficulty: 'hard' },
      expert: { attempts: 5, hints: 1, difficulty: 'expert' }
    }.freeze
    RANGE_OF_DIGITS = 1..6.freeze
    GUESS_CODE = { hint: 'hint', leave: 'exit' }.freeze

    attr_reader :date, :got_hints, :secret_code, :name, :hints_total, :have_hints, :attempts_total, :hints_used, :attempts_used, :difficulty, :winner, :attempts_left
    attr_accessor :errors

    def game_options(user_difficulty:, player:)
      @got_hints = ''
      @hints_used = 0
      @attempts_used = 0
      @name = player.name
      assign_difficulty(DIFFICULTIES[user_difficulty.downcase.to_sym])
    end

    def attempt(input)
      @errors = []
      return use_hint if hint?(input)

      converted = convert_to_array(input)
      return guessing(converted) if valid_input?(input, AMOUNT_DIGITS)
      miss_input && return
    end

    def miss_input
      @errors << I18n.t(:when_incorrect_guess) && return
    end

    def valid_difficulties?(input)
      DIFFICULTIES.key?(input.to_sym)
    end

    def remove_instance_helpers
      remove_instance_variable(:@winner) if @winner
      remove_instance_variable(:@errors) if @errors
      remove_instance_variable(:@hints_array) if @hints_array
      remove_instance_variable(:@have_hints) if @have_hints
    end

    def secret_code
      @secret_code ||= Array.new(AMOUNT_DIGITS) { rand(RANGE_OF_DIGITS) }.join('')
      convert_to_array(@secret_code)
    end

    private

    def hint?(input)
      input == GUESS_CODE[:hint]
    end

    def convert_to_array(input)
      input.chars.map(&:to_i)
    end

    def assign_difficulty(difficulty_of_variables)
      @attempts_total = difficulty_of_variables[:attempts]
      @hints_total = difficulty_of_variables[:hints]
      @have_hints = difficulty_of_variables[:hints]
      @attempts_left = @attempts_total
      @difficulty = difficulty_of_variables[:difficulty]
    end

    def valid_input?(entity, length)
      return unless validate_presence?(entity)
      return unless validate_length(entity, length)
      return unless validate_match(entity)

      valid_digits?(entity, RANGE_OF_DIGITS)
    end

    def count_attempt
      @attempts_left -= INCREMENT
      @attempts_used += INCREMENT
    end

    def use_hint
      @errors << I18n.t(:when_no_hints) && return unless @have_hints.positive?
      count_tip
    end

    def count_tip
      @have_hints -= INCREMENT
      @hints_used += INCREMENT
      @hints_array ||= secret_code.clone.shuffle
      hint = @hints_array.pop.to_s
      @got_hints += hint
      hint
    end

    def compare_with_right_code(user_code)
      user_code == secret_code
    end

    def guessing(user_code)
      count_attempt
      @date = Time.new and return @winner = true if compare_with_right_code(user_code)

      pin = []
      clone_secret_code = secret_code.clone
      complex_code = user_code.zip(secret_code)
      complex_code.map do |user_digit, secret_digit|
        next unless user_digit == secret_digit

        pin << POSITIVE_DIGIT
        user_code.delete_at(user_code.index(user_digit))
        clone_secret_code.delete_at(clone_secret_code.index(secret_digit))
      end
      clone_secret_code.each do |digit|
        next unless user_code.include? digit
          pin << NEGATIVE_DIGIT
          user_code.delete_at(user_code.index(digit))
      end
      pin.sort.join('')
    end
  end
end
