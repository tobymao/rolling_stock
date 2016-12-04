require './spec/spec_helper'

describe Corporation do
  let(:player) { Player.new 1, 'Test' }
  let(:market) { SharePrice.initial_market }
  let(:share_price) { market[6] }
  let(:company) { Company.new player, *(['BME'].concat Company::COMPANIES['BME']) }
  subject { Corporation.new 'Bear', company, share_price, market }

  describe '#buy_company' do
    let(:company_to_buy) { Company.new player, *(['BSE'].concat Company::COMPANIES['BSE']) }

    it 'cash gets removed' do
      expect { subject.buy_company company_to_buy, 10 }.to change { subject.cash }.by(-10)
    end

    it 'adds company to companies' do
      expect(subject.companies.find { |c| c == company_to_buy }).to be_nil
      subject.buy_company company_to_buy, 10
      expect(subject.companies.find { |c| c == company_to_buy }).to eq(company_to_buy)
    end

    it 'removes company from seller' do
      player.companies << company_to_buy
      expect { subject.buy_company company_to_buy, 10}.to change { player.companies.size }.by(-1)
    end
  end
end
