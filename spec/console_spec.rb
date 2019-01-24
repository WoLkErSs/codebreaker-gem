require 'spec_helper'

module Codebreaker
  RSpec.describe Console do
    let(:respondent_double) { double('Respondent') }
    let(:game_double) { double('Game') }
    let(:player_double) { double('Player') }
    let(:rules_double) { double('Rules') }
    let(:statistics_double) { double('Statistics') }

    let(:name) { 'Boba' }
    let(:difficulty) { 'easy' }
    DIFFICULTIES = {
      easy: 'easy',
      medium: 'hard',
      hell: 'expert'
    }.freeze

    describe '#choose_action' do
      it 'when call process' do
        allow(respondent_double).to receive(:show_message).with(:greeting)
        allow(respondent_double).to receive(:show_message).with(:choose_action)
        allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:start])
        expect(subject).to receive(:process)
        subject.choose_action
      end

      it 'when call rules' do
        allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:rules], Console::USER_ACTIONS[:start])
        allow(subject).to receive(:rules).and_return(rules_double)
        allow(rules_double).to receive(:show_rules)
        allow(subject).to receive(:process)
        expect(rules_double).to receive(:show_rules)
        subject.choose_action
      end

      it 'with call statistics' do
        allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:stats], Console::USER_ACTIONS[:start])
        allow(subject).to receive(:process)
        expect(subject).to receive(:show_statistics)
        subject.choose_action
      end

      it 'with invalid action' do
        allow(subject).to receive(:input).and_return('', Console::USER_ACTIONS[:start])
        allow(subject).to receive(:respondent).and_return(respondent_double)
        allow(respondent_double).to receive(:show_message)
        allow(subject).to receive(:process)
        expect(respondent_double).to receive(:show_message).with(:wrong_input_action)
        subject.choose_action
      end
    end

    describe '.leave' do
      it 'when leave app' do
        allow(subject).to receive_message_chain(:gets, :chomp, :downcase).and_return('exit', 'start')
        expect(subject).to receive(:exit)
        expect(subject).to receive(:process)
        subject.choose_action
      end
    end

    describe '.process assing name and difficulty' do
      before do
        allow(subject.instance_variable_set(:@player, player_double))
        allow(subject.instance_variable_set(:@game, game_double))
        allow(game_double).to receive(:game_options)
      end

      it 'when invalid/valid name' do
        allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:start], '', name)
        allow(subject).to receive(:respondent).and_return(respondent_double)
        allow(respondent_double).to receive(:show)
        allow(respondent_double).to receive(:show_message)
        allow(player_double).to receive(:errors_store)
        allow(player_double).to receive(:assign_name)
        allow(player_double).to receive(:valid?).and_return(false, true)
        allow(subject).to receive(:setup_difficulty)
        expect(subject).to receive(:play_game)
        subject.choose_action
      end

      it 'when invalid/valid difficulty' do
        allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:start], '', difficulty)
        allow(subject).to receive(:player).and_return(game_double)
        allow(game_double).to receive(:valid_difficulties?).and_return(false, true)
        allow(subject).to receive(:setup_player)
        expect(subject).to receive(:play_game)
        subject.choose_action
      end

      it 'check each difficulty' do
        allow(game_double).to receive(:valid_difficulties?).and_return(true)
        allow(subject).to receive(:setup_player)
        DIFFICULTIES.each do |_key, value|
          allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:start], name, value)
        end
        expect(subject).to receive(:play_game)
        subject.choose_action
      end
    end

    describe '.process play' do
      let(:some_guessed) { '+++' }
      let(:user_code) { '1234' }
      let(:hint) { 'hint' }
      let(:invalid_code) { '' }

      before do
        allow(subject).to receive(:input).and_return(Console::USER_ACTIONS[:start], name, difficulty, invalid_code, user_code)
        allow(subject).to receive(:respondent).and_return(respondent_double)
        allow(respondent_double).to receive(:show_message)
        allow(respondent_double).to receive(:show)
        allow(subject).to receive(:game).and_return(game_double)
        allow(subject).to receive(:setup_difficulty)
        allow(subject).to receive(:setup_player)
        allow(subject).to receive(:game_state_valid?).and_return(true, false)
        allow(game_double).to receive(:winner).and_return(false)
        allow(game_double).to receive(:game_options)
        end

      it 'when use hint' do
        allow(game_double).to receive(:attempt).and_return(1)
        allow(game_double).to receive(:errors).and_return([])
        expect(respondent_double).to receive(:show).with(1)
        expect(subject).to receive(:result_decision)
        subject.choose_action
      end

      it 'when no hints' do
        allow(game_double).to receive(:attempt).and_return(nil)
        allow(game_double).to receive(:errors).and_return([I18n.t(:when_no_hints)])
        expect(respondent_double).to receive(:show).with([I18n.t(:when_no_hints)])
        expect(subject).to receive(:result_decision)
        subject.choose_action
      end

      it 'when invalid code passed' do
        allow(game_double).to receive(:attempt).and_return(nil)
        allow(game_double).to receive(:errors).and_return([I18n.t(:when_incorrect_guess)])
        expect(respondent_double).to receive(:show).with([I18n.t(:when_incorrect_guess)])
        expect(subject).to receive(:result_decision)
        subject.choose_action
      end

      it 'when did not guess the code' do
        allow(game_double).to receive(:attempt).and_return(some_guessed)
        allow(game_double).to receive(:errors).and_return([])
        expect(respondent_double).to receive(:show).with(some_guessed)
        expect(subject).to receive(:result_decision)
        subject.choose_action
      end

      it 'when player guessed the code - win' do
        allow(game_double).to receive(:winner).and_return(true)
        allow(game_double).to receive(:attempt).and_return(true)
        allow(game_double).to receive(:errors).and_return([])
        allow(game_double).to receive(:remove_instance_helpers)
        expect(respondent_double).to receive(:show_message)
        expect(subject).to receive(:new_process)
        subject.choose_action
      end

      it 'when player lose' do
        allow(game_double).to receive(:remove_instance_helpers)
        allow(game_double).to receive(:attempt).and_return(true)
        allow(game_double).to receive(:errors).and_return([])
        expect(subject).to receive(:new_process)
        subject.choose_action
      end

      it 'with statistics output' do
        allow(subject).to receive(:input).and_return('stats', 'start')
        allow(respondent_double).to receive(:show_message)
        allow(respondent_double).to receive(:show)
        allow(statistics_double).to receive(:winners)
        allow(subject.instance_variable_set(:@statistic, statistics_double))
        allow(subject).to receive(:respondent).and_return(respondent_double)
        expect(subject).to receive(:process)
        subject.choose_action
      end
    end
  end
end
