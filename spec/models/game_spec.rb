require './spec/spec_helper'

describe Game do
  let(:player) { Player.new 1 }
  let(:company)  { Company.new 'BME', 'Bergisch', :red, 1, 1, [] }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  let(:corporation) { Corporation.new 'Android', player, company, share_price, SharePrice.initial_market }
  let(:user) { create :user }
  subject { create :game }

  before :each do
    subject.load
  end

  it 'should init' do
    expect(subject).not_to be_nil
  end

  describe '#issue_share' do
    it 'increase corp cash by 9' do
      expect {
        subject.issue_share(player, corporation)
      }.to change {
        corporation.cash
      }.by 9
    end
  end
end
