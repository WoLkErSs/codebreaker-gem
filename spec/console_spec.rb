RSpec.describe Console::Codebreaker do
  let(:respondent_double) {double('Respondent')}
  let(:process_helper_double) {double('ProcessHelper')}
  let(:game_double) {double('Game')}
  let(:player_double) {double('Player')}
  let(:rules_double) {double('Rules')}
  let(:statistics_double) { double('Statistics') }

  describe '#choose_action' do
    context 'when call process' do
      it do
        allow(subject).to receive(:input).and_return('start')
        allow(respondent_double).to receive(:show_message).and_return(I18n.t(:choose_action))
        allow(subject.instance_variable_set(:@instance_respondent, respondent_double))
        expect(subject).to receive(:instance_respondent)
        expect(subject.instance_variable_get(:@instance_respondent)).to receive(:show_message).and_return(I18n.t(:choose_action))
        expect(subject).to receive(:process)
        subject.choose_action
      end
    end

    context 'when call rules' do
      it do
        allow(subject).to receive(:input).and_return('rules', 'start')
        allow(subject.instance_variable_set(:@instance_rules, rules_double))
        allow(subject).to receive(:process)
        expect(subject.instance_variable_get(:@instance_rules)).to receive(:show_rules)
        subject.choose_action
      end
    end

    context 'with call statistics' do
      it do
        allow(subject).to receive(:input).and_return('stats', 'start')
        allow(subject).to receive(:process)
        expect(subject).to receive(:statistics)
        subject.choose_action
      end
    end

    context 'with invalid action' do
      it do
        allow(subject).to receive(:input).and_return('staawdawdts', 'start')
        allow(subject).to receive(:instance_respondent)
        allow(subject).to receive(:process)
        allow(subject.instance_variable_get(:@instance_respondent)).to receive(:show_message).with(:choose_action)
        allow(subject.instance_variable_get(:@instance_respondent)).to receive(:show_message).with(:greeting)
        expect(subject.instance_variable_get(:@instance_respondent)).to receive(:show_message).with(:wrong_input_action)
        subject.choose_action
      end
    end
  end

  describe '.process' do
    let(:has_not_attempt) {0}
    let(:some_guessed) {'+++'}
    let(:guessed_code) {'++++'}

    it 'when leave app' do
      allow(respondent_double).to receive(:show_message)
      allow(subject.instance_variable_set(:@instance_respondent, respondent_double))
      allow(subject).to receive_message_chain(:gets, :chomp, :downcase).and_return('exit')
      expect(subject).to receive(:exit)
      subject.send(:input)
    end

    it 'when invalid input during play' do
      allow(subject).to receive(:input).and_return('start', '')
      allow(subject.instance_variable_set(:@instance_process_helper, process_helper_double))
      allow(subject).to receive(:game_state_valid?).and_return(true, false)
      allow(game_double).to receive(:attempt).and_return(nil)
      allow(game_double).to receive(:errors).and_return([I18n.t(:when_incorrect_guess)])
      allow(subject.instance_variable_set(:@instance_game, game_double))
      allow(process_helper_double).to receive(:setup_player)
      allow(process_helper_double).to receive(:setup_difficulty)
      expect(subject).to receive(:instance_game)
      expect(subject).to receive(:set_game_options)
      expect(subject).to receive(:result_decision)
      subject.choose_action
    end

    it 'when valid but wrong code passed' do
      allow(subject).to receive(:input).and_return('start', '1233')
      allow(subject).to receive(:game_state_valid?).and_return(true, false)
      allow(subject.instance_variable_set(:@instance_process_helper, process_helper_double))
      allow(process_helper_double).to receive(:setup_player)
      allow(process_helper_double).to receive(:setup_difficulty)
      allow(subject.instance_variable_set(:@instance_game, game_double))
      allow(game_double).to receive(:game_options)
      allow(game_double).to receive(:errors).and_return([])
      allow(game_double).to receive(:attempt).and_return(:some_guessed)
      allow(respondent_double).to receive(:show_message)
      allow(subject.instance_variable_set(:@instance_respondent, respondent_double))
      expect(subject.instance_variable_get(:@instance_respondent)).to receive(:show).with(:some_guessed)
      expect(subject).to receive(:result_decision)
      subject.choose_action
    end

    it 'when attempts have had been spent - lose' do
      allow(subject).to receive(:input).and_return('start')
      allow(subject.instance_variable_set(:@instance_process_helper, process_helper_double))
      allow(process_helper_double).to receive(:setup_player)
      allow(process_helper_double).to receive(:setup_difficulty)
      allow(subject).to receive(:set_game_options)
      allow(subject.instance_variable_set(:@instance_game, game_double))
      allow(game_double).to receive(:winner).and_return(nil)
      allow(game_double).to receive(:attempts_left).and_return(has_not_attempt)
      allow(respondent_double).to receive(:show_message)
      allow(subject.instance_variable_set(:@instance_respondent, respondent_double))
      expect(subject).to receive(:new_process)
      subject.choose_action
    end

    it 'when guessed code - win and agree to save result' do
      allow(subject).to receive(:input).and_return('start' , '1234', 'y')
      allow(subject).to receive(:game_state_valid?).and_return(true, false)
      allow(subject.instance_variable_set(:@instance_process_helper, process_helper_double))
      allow(process_helper_double).to receive(:setup_player)
      allow(process_helper_double).to receive(:setup_difficulty)
      allow(subject.instance_variable_set(:@instance_game, game_double))
      allow(game_double).to receive(:attempt).and_return(:guessed_code)
      allow(game_double).to receive(:errors).and_return([])
      allow(subject).to receive(:set_game_options)
      allow(game_double).to receive(:winner).and_return(true)
      allow(subject.instance_variable_set(:@instance_game, game_double))
      expect(subject).to receive(:save_to_db)
      expect(subject).to receive(:new_process)
      subject.choose_action
    end

    it 'when guessed code - win and do not save result' do
      allow(subject).to receive(:input).and_return('start' , '1234', 'y')
      allow(subject).to receive(:game_state_valid?).and_return(true, false)
      allow(subject.instance_variable_set(:@instance_process_helper, process_helper_double))
      allow(process_helper_double).to receive(:setup_player)
      allow(process_helper_double).to receive(:setup_difficulty)
      allow(subject.instance_variable_set(:@instance_game, game_double))
      allow(game_double).to receive(:attempt).and_return(:guessed_code)
      allow(game_double).to receive(:errors).and_return([])
      allow(subject).to receive(:set_game_options)
      allow(game_double).to receive(:winner).and_return(true)
      allow(subject.instance_variable_set(:@instance_game, game_double))
      expect(subject).to receive(:new_process)
      subject.choose_action
    end

    it 'with statistics output' do
      allow(subject).to receive(:input).and_return('stats', 'start')
      allow(respondent_double).to receive(:show_message)
      allow(respondent_double).to receive(:show)
      allow(statistics_double).to receive(:winners)
      allow(subject.instance_variable_set(:@instance_statistic, statistics_double))
      allow(subject.instance_variable_set(:@instance_respondent, respondent_double))
      expect(subject).to receive(:process)
      expect(subject.instance_variable_get(:@instance_respondent)).to receive(:show)
      subject.choose_action
    end
  end
end

RSpec.describe Statistics do
  subject { described_class.new }
  let(:game_double) {instance_double('Game', name: 'Moroz', difficulty: 'easy', attempts_total: 10, attempts_used: 2, hints_total: 2, hints_used: 4)}
  describe '#winners' do
    context 'show winners table' do
      it do
        expect(subject.send(:multi_sort, [game_double])).to be_an_instance_of(Array)
        expect(subject.send(:to_table, [game_double])).to be_an_instance_of(Array)
        expect(subject.send(:to_table, [game_double])).to be_an_instance_of(Array)
        subject.winners([game_double])
      end
    end
  end
end
