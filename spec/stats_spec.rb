require 'spec_helper'

module Codebreaker
  RSpec.describe Statistics do
    subject { described_class.new }
    let(:game_double) {instance_double('Game', name: 'Moroz', difficulty: 'easy', attempts_total: 10, attempts_used: 2, hints_total: 2, hints_used: 4)}
    describe '#winners' do
      context 'show winners table' do
        it do
          expect(subject.winners([game_double])).to be_an_instance_of(Array)
        end
      end
    end
  end
end
