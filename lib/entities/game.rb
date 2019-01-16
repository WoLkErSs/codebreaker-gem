module Codebreaker
  class Game
    include Validation

    AMOUNT_DIGITS = 4
    DIFFICULTIES = {
      easy: { attempts: 15, hints: 2, difficulty: 'easy' },
      hard: { attempts: 10, hints: 2, difficulty: 'hard' },
      expert: { attempts: 5, hints: 1, difficulty: 'expert' }
    }.freeze
    RANGE_OF_DIGITS = 0..4.freeze
    GUESS_CODE = { hint: 'hint', leave: 'exit' }.freeze

    attr_reader :name, :hints_total, :attempts_total, :hints_used, :attempts_used, :difficulty, :winner, :attempts_left
    attr_accessor :errors

    def initialize
      @hints_used = 0
      @attempts_used = 0
    end

    def game_options(user_difficulty:, player:)
      @name = player.name
      assign_difficulty(DIFFICULTIES[user_difficulty.downcase.to_sym])
    end

    def attempt(input)
      return use_hint if hint?(input)

      converted = convert_to_array(input)
      guessing(converted) if check_input(input)
    end

    def valid_difficulties?(input)
      DIFFICULTIES.key?(input.to_sym)
    end

    private

    def hint?(input)
      input == GUESS_CODE[:hint]
    end

    def convert_to_array(input)
      input.split('').map(&:to_i)
    end

    def assign_difficulty(difficulty_of_variables)
      @attempts_total = difficulty_of_variables[:attempts]
      @hints_total = difficulty_of_variables[:hints]
      @attempts_left = @attempts_total
      @difficulty = difficulty_of_variables[:difficulty]
    end

    def check_input(entity)
      @errors = []
      return count_attempt if validation(entity, AMOUNT_DIGITS)

      @errors << I18n.t(:when_incorrect_guess) && return
    end

    def validation(entity, length)
      return if validate_presence?(entity)
      return unless validate_length(entity, length)
      return if entity == GUESS_CODE[:hint]

      validate_match(entity)
    end

    def count_attempt
      @attempts_left -= 1
      @attempts_used += 1
    end

    def use_hint
      @errors = []
      @errors << I18n.t(:when_no_hints) && return unless @hints_total.positive?
      count_tip
    end

    def count_tip
      @hints_total -= 1
      @hints_used += 1
      arr_for_hints = secret_code.clone.shuffle
      arr_for_hints.pop
    end

    def compare_with_right_code(user_code)
      user_code == secret_code
    end

    def secret_code
      @secret_code ||= Array.new(AMOUNT_DIGITS) { rand(RANGE_OF_DIGITS) }
    end

    def guessing(user_code)
      @winner = true && return if compare_with_right_code(user_code)

      pin = []
      clone_secret_code = secret_code.clone
      a = user_code.zip(secret_code)
      a.map do |user_digit, secret_digit|
        next unless user_digit == secret_digit

        pin << '+'
        user_code.delete_at(user_code.index(user_digit))
        clone_secret_code.delete_at(clone_secret_code.index(secret_digit))
      end
      clone_secret_code.each do |x|
        if user_code.include? x
          pin << '-'
          user_code.delete_at(user_code.index(x))
        end
      end
      pin.sort.join('')
    end
  end
end
