require './spec/spec_helper'

describe Game do
  let(:user) { User.new }
  let(:company)  { Company.new 'BME', 'Bergisch', :red, 1, 1, [] }
  let(:share_price) { SharePrice.initial_market[6] }
  let(:corporation)  {
    Corporation.new 'Android', user, company, share_price, SharePrice.initial_market

  }

  it 'should init' do
    expect(Game.new).not_to be_nil
  end

  describe '#issue_share' do
    it 'should issue a share' do
      expect {
        subject.issue_share(user, corporation)
      }.to change {
        corporation.cash
      }.by 9
    end
  end
end
