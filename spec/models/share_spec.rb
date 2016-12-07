require './spec/spec_helper'

describe Share do
  let(:player) { Player.new 1, 'Test' }
  let(:company) { Company.all['BME'].dup }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  let(:corporation) { Corporation.new 'Android', company, share_price, SharePrice.initial_market }
  subject { Share.new :corporation, true }

  it 'should init' do
    expect(subject).not_to be_nil
  end

  describe '#initialize' do
    it 'should set variables correctly' do
      expect(subject.corporation).not_to be_nil
    end
  end

  describe '#president?' do
    it 'should return true for the presidents share' do
      expect(subject.president?).to eq(true)
    end
  end


end
