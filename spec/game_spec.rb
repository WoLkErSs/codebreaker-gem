RSpec.describe Game::Codebreaker do
  let(:player_name) {'Gilly'}
  let(:player_double) {class_double('Player', player_name)}
  let(:user_difficulty) {'easy'}

  describe '.assign_difficulty' do
    let(:attempts_quantity) {15}
    let(:hints_quantity) {2}
    let(:attempts_quantity_left) {15}
    context 'assign settings' do
      it do
        subject.game_options(user_difficulty: user_difficulty, player: player_double)
        expect(subject.instance_variable_get(:@attempts_total)).to eq(attempts_quantity)
        expect(subject.instance_variable_get(:@hints_total)).to eq(hints_quantity)
        expect(subject.instance_variable_get(:@attempts_left)).to eq(attempts_quantity_left)
        expect(subject.instance_variable_get(:@difficulty)).to eq('easy')
      end
    end
  end

  describe '#attempt' do
    let(:hint) {'hint'}
    let(:user_code) {'1234'}
    let(:wrong_input) {'12wda34'}
    let(:just_input) {[4,5,6,7]}
    let(:just_input2) {[7,5,6,4]}
    let(:right_input) {['+','+','+','+']}

    context 'with user input' do
      it 'with use hint' do
        allow(subject.instance_variable_set(:@hints_total, 2))
        allow(subject.instance_variable_set(:@hints_used, 2))
        allow(subject.instance_variable_set(:@errors, []))
        allow(subject.instance_variable_set(:@arr_for_hints, [1, 2, 3, 4]))
        expect {subject.attempt(hint)}.to change{subject.hints_total}.by(-1)
        expect {subject.attempt(hint)}.to change{subject.hints_used}.by(1)
        subject.attempt(hint)
      end

      it 'when have not hints' do
        allow(subject.instance_variable_set(:@hints_total, 0))
        subject.attempt(hint)
        expect(subject.instance_variable_get(:@errors)).to eq([I18n.t(:when_no_hints)])
      end

      it 'when valid input' do
        allow(subject.instance_variable_set(:@attempts_left, 2))
        allow(subject.instance_variable_set(:@attempts_used, 2))
        expect(subject).to receive(:guessing)
        subject.attempt(user_code)
      end

      it 'when invalid input' do
        expect(subject.attempt(wrong_input)).to eq(nil)
      end
    end

    context 'check validate work of .guessing' do
      [
        [[6, 5, 4, 1], '6541', nil],
        [[1, 2, 3, 4], '5612', '--'],
        [[5, 5, 6, 6], '5600', '+-'],
        [[6, 2, 3, 5], '2365', '+---'],
        [[1, 2, 3, 4], '4321', '----'],
        [[1, 2, 3, 4], '1235', '+++'],
        [[1, 2, 3, 4], '6254', '++'],
        [[1, 2, 3, 4], '5635', '+'],
        [[1, 2, 3, 4], '4326', '---'],
        [[1, 2, 3, 4], '3525', '--'],
        [[1, 2, 3, 4], '2552', '-'],
        [[1, 2, 3, 4], '4255', '+-'],
        [[1, 2, 3, 4], '1524', '++-'],
        [[1, 2, 3, 4], '5431', '+--'],
        [[1, 2, 3, 4], '6666', '']
      ].each do |item|
        it "return #{item[2]} if code is - #{item[0]}, guess_code is #{item[1]}" do
          subject.instance_variable_set(:@attempts_left, 1)
          subject.instance_variable_set(:@attempts_used, 0)

          subject.instance_variable_set(:@secret_code, item[0])
          expect(subject.attempt(item[1])).to eq item[2]
        end
      end
    end
  end

  describe '#valid_difficulties?' do
    let(:invalid_input) {'ysae'}
    let(:valid_input) {'easy'}

    it 'when valid difficulty' do
      expect(subject.valid_difficulties?(invalid_input)). to eq(false)
    end

    it 'when invalid difficulty' do
      expect(subject.valid_difficulties?(valid_input)). to eq(true)
    end
  end
end
