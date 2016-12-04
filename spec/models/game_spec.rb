require './spec/spec_helper'

describe Game do
  let(:player) { Player.new 1, 'Test' }
  let(:company) { Company.new player, 'BME', 'Bergisch', :red, 1, 1, [] }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  let(:corporation) { Corporation.new 'Android', company, share_price, SharePrice.initial_market }
  let(:user) { create :user }
  subject { create :game }


  before :each do
    subject.load
  end

  it 'should init' do
    expect(subject).not_to be_nil
  end

  describe '#load' do
    context 'with 3 players' do
      subject { create :game, users: 3.times.map { create(:user).id } }

      it 'should create deck' do
        expect(subject.company_deck.size).to eq(24)
      end
    end

    context 'with 4 players' do
      subject { create :game, users: 4.times.map { create(:user).id } }

      it 'should create deck' do
        expect(subject.company_deck.size).to eq(31)
      end
    end

    context 'with 5 players' do
      subject { create :game, users: 5.times.map { create(:user).id } }

      it 'should create deck' do
        expect(subject.company_deck.size).to eq(38)
      end
    end
  end

  describe '#collect_income' do
    it 'should increase cash for corporations and players' do
      allow(subject).to receive(:players).and_return(player.id => player)
      player.companies << company
      expect {
        subject.collect_income
      }.to change { player.cash
      }.by 1
    end
  end

  describe '#issue_share' do
    it 'increase corp cash by 9' do
      expect {
        subject.issue_share corporation
      }.to change {
        corporation.cash
      }.by 9
    end
  end
end

def mock_players players
  allow(subject).to receive(:players).and_return(players)
end

