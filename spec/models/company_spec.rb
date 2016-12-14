require './spec/spec_helper'

describe Company do
  let(:player) { Player.new 1, 'Test' }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  subject { Company.new player, "MM", 'Mars Mining Associates', :purple, 75, 25, ['LHR', 'FRA', 'LE', 'TSI'] }


  describe '#initialize' do
    it 'should provision variables' do
      expect(subject.name).not_to be_nil
    end
  end

  describe '#id' do
    it 'should return the name' do
      expect(subject.id).to eq("MM")
    end
  end

  describe '#valid_price?' do
    it 'should not allow double the company price' do
      expect(subject.valid_price? 200).to eq(false)
    end
    it 'should allow a price of 100' do
      expect(subject.valid_price? 100).to eq(true)
    end
  end

  describe '#min_price' do
    it 'should be half of cost' do
      expect(subject.min_price).to eq(38)
    end
  end

  describe '#max_price' do
    it 'should be higher than ...' do
      expect(subject.max_price).to eq(112)
    end
  end

end
