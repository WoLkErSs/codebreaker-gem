RSpec.describe ProcessHelper::Codebreaker do
  let(:player_double) {double('Player', assign_name: 'Gilly')}
  let(:output_double) {double('Respondent')}

  describe '#new' do
    context 'when screate subject' do
      it {expect(subject.instance_variable_get(:@player)).to be_an_instance_of(Player)}
      it {expect(subject.instance_variable_get(:@output)).to be_an_instance_of(Respondent)}
      it {expect(subject.instance_variable_get(:@game)).to be_an_instance_of(Game)}
    end
  end

  describe '#setup_player' do
    let(:name) {'Gilly'}
    before do
      allow(output_double).to receive(:show_message)
      allow(subject.instance_variable_set(:@output, output_double))
      allow(subject.instance_variable_set(:@player, player_double))
      allow(player_double).to receive(:errors_store)
      allow(player_double).to receive(:assign_name)
      player_double.stub(:name) {name}

    end
    it 'when inputed right name' do
      allow(player_double).to receive(:valid?).and_return(true)
      allow(subject).to receive_message_chain(:gets, :chomp).and_return(name)
      expect(subject.setup_player).to be(player_double)
    end

    it 'when inputed invalid name' do
      allow(player_double).to receive(:valid?).and_return(false, true)
      allow(output_double).to receive(:show)
      allow(subject).to receive_message_chain(:gets, :chomp).and_return('f', name)
      expect(subject.instance_variable_get(:@output)).to receive(:show)
      subject.setup_player
    end
  end

  describe '#setup_difficulty' do
    let(:invalid_difficulty) {'ysae'}
    let(:valid_difficulty) {'easy'}

    it 'when input difficulty' do
      allow(output_double).to receive(:show_message)
      allow(subject.instance_variable_set(:@output, output_double))
      allow(subject).to receive_message_chain(:gets, :chomp, :downcase).and_return(invalid_difficulty, valid_difficulty)
      expect(subject.instance_variable_get(:@output)).to receive(:show_message)
      expect(subject.setup_difficulty).to eq(valid_difficulty)
      subject.setup_difficulty
    end

    it 'when want to exit' do
      allow(output_double).to receive(:show_message)
      allow(subject.instance_variable_set(:@output, output_double))
      allow(subject).to receive_message_chain(:gets, :chomp).and_return('exit')
      expect(subject.setup_difficulty).to raise_error(SystemExit)
    end
  end
end
