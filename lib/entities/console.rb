module Codebreaker
  class Console
    include Database
    USER_ACTIONS = {
      start: 'start',
      rules: 'rules',
      stats: 'stats',
      leave: 'exit'
    }.freeze
    ACTIONS_FOR_DATABASE = {
      save_player: 'y'
    }.freeze

    def choose_action
      instance_respondent
      instance_rules
      @instance_respondent.show_message(:greeting)
      loop do
        @instance_respondent.show_message(:choose_action)
        case input
        when USER_ACTIONS[:start] then return process
        when USER_ACTIONS[:rules] then @instance_rules.show_rules
        when USER_ACTIONS[:stats] then statistics
        else @instance_respondent.show_message(:wrong_input_action)
        end
      end
    end

    private

    def instance_process_helper
      @instance_process_helper ||= ProcessHelper.new
    end

    def instance_rules
      @instance_rules ||= Rules.new
    end

    def instance_game
      @instance_game ||= Game.new
    end

    def instance_respondent
      @instance_respondent ||= Respondent.new
    end

    def process
      instance_game
      instance_process_helper
      @player = @instance_process_helper.setup_player
      @difficulty = @instance_process_helper.setup_difficulty
      set_game_options
      play_game
    end

    def set_game_options
      @instance_game.game_options(user_difficulty: @difficulty, player: @player)
    end

    def play_game
      @instance_respondent.show_message(:in_process)
      while game_state_valid?
        what_guessed = @instance_game.attempt(input)
        @instance_respondent.show(what_guessed) if what_guessed
        @instance_respondent.show(@instance_game.errors) unless @instance_game.errors.empty?
      end
      result_decision
    end

    def game_state_valid?
      @instance_game.attempts_left.positive? && !@instance_game.winner
    end

    def result_decision
      @instance_game.winner ? win : lose
    end

    def lose
      @instance_respondent.show_message(:when_lose)
      new_process
    end

    def win
      @instance_respondent.show_message(:when_win)
      save_to_db(@instance_game) if input == ACTIONS_FOR_DATABASE[:save_player]
      new_process
    end

    def new_process
      choose_action
    end

    def input
      input = gets.chomp.downcase
      input == USER_ACTIONS[:leave] ? leave : input
    end

    def leave
      @instance_respondent.show_message(:leave)
      exit
    end

    def statistics
      instance_statistic
      @instance_respondent.show(winners_load)
    end

    def winners_load
      @instance_statistic.winners(load_db)
    end

    def instance_statistic
      @instance_statistic ||= Statistics.new
    end
  end
end
