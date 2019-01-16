module Codebreaker
  class ProcessHelper
    AVAILABLE_ACTIONS = {
      start: 'start',
      rules: 'rules',
      stats: 'stats',
      leave: 'exit',
      save_player: 'y'
    }.freeze

    def initialize
      @player = Player.new
      @output = Respondent.new
      @game = Game.new
    end

    def setup_player
      @output.show_message(:ask_name)
      loop do
        @player.assign_name(input.capitalize)
        next @output.show(@player.errors_store) unless @player.valid?
        return @player if @player.name
      end
    end

    def setup_difficulty
      loop do
        @output.show_message(:select_difficulty)
        user_difficulty_input = input
        return user_difficulty_input if @game.valid_difficulties?(user_difficulty_input)
      end
    end

    private

    def input
      input = gets.chomp.downcase
      leave if input == AVAILABLE_ACTIONS[:leave]
      input
    end

    def leave
      @output.show_message(:leave)
      exit
    end
  end
end
