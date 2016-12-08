require './spec/spec_helper'

describe Player do
  #let(:company) { Company.all['BME'].dup }
  let(:player) { Player.new 1, 'Test' }
  let(:company) { Company.new player, *(['BSE'].concat Company::COMPANIES['BSE']) }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  let(:corporation) { Corporation.new 'Android', company, share_price, SharePrice.initial_market }
  subject { Player.new 1, "TestUser" }

  describe '#initialize' do
    it 'should provision variables' do
      expect(subject.id).not_to be_nil
      expect(subject.name).not_to be_nil
      expect(subject.companies).not_to be_nil
      expect(subject.shares).not_to be_nil
      expect(subject.cash).to eq(30)
    end
  end

  describe '#value' do
    it 'should not change after buying a share.' do
      corporation.buy_share subject
      expect { corporation.buy_share subject }.to change { subject.value }.by(0)
    end
  end

end
