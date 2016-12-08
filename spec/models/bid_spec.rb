require './spec/spec_helper'

describe Bid do
  let(:player) { Player.new 1, 'Test' }
  let(:company) { Company.all['BME'].dup }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  let(:corporation) { Corporation.new 'Android', company, share_price, SharePrice.initial_market }
  subject { Bid.new player, company, 10 }


  describe '#initialize' do
    it 'should provision variables' do
      expect(subject.player).to be(player)
      expect(subject.company).to be(company)
      expect(subject.price).to eq(10)
    end
  end

end
