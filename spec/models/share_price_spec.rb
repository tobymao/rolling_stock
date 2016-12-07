require './spec/spec_helper'

describe SharePrice do
  let(:player) { Player.new 1, 'Test' }
  let(:company) { Company.all['BME'].dup }
  subject { SharePrice.initial_market[1] }

  it 'should init' do
    expect(subject).not_to be_nil
  end

  describe '#initialize' do
    it 'should set variables correctly' do
      expect(subject.price).to eq(5)
      expect(subject.index).to eq(1)
    end
  end

  describe '#valid_range?' do
    it 'should not be a valid range.' do
      expect(subject.valid_range? company).to eq(false)
    end
  end


end
