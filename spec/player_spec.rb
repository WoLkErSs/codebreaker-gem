require 'spec_helper'

module Codebreaker
  RSpec.describe Player do
    let(:correct_input) {'I' * max_length}
    let(:less_then_correct_input) { 'I' * (min_length - 1) }
    let(:greater_then_correct_input) { 'I'*(max_length + 1) }
    let(:min_length) {3}
    let(:max_length) {20}

    describe '#assign_name(input)' do
      it 'with right pass name' do
        expect(subject.assign_name(correct_input)).to eq(correct_input)
      end

      it 'with invali name' do
        expect(subject.assign_name(:greater_then_correct_input)).to eq([I18n.t(:when_wrong_name, min: min_length, max: max_length)])
      end
    end

    describe '#valid?' do
      it 'when true' do
        allow(subject.instance_variable_set(:@errors_store, []))
        expect(subject.valid?).to eq(true)
      end

      it 'when false' do
        allow(subject.instance_variable_set(:@errors_store, [I18n.t(:when_wrong_name, min: min_length, max: max_length)]))
        expect(subject.valid?).to eq(false)
      end
    end
  end
end
