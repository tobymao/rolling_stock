require './spec/spec_helper'

describe Company do
  let(:player) { Player.new 1, 'Test' }
  let(:share_price) { SharePrice.initial_market[6] } # 10, 6
  subject { Company.new player, "MM", 'Mars Mining Associates', :purple, 75, 25, ['LHR', 'FRA', 'LE', 'TSI'] }

  describe '#id' do
    it 'should return the name' do
      expect(subject.id).to eq("MM")
    end
  end

  describe '#can_be_sold?' do
    context 'owned by player' do
      it 'should be true' do
        expect(subject.can_be_sold?).to be_truthy
      end

      it 'should be false if sold recently' do
        subject.recently_sold = true
        expect(subject.can_be_sold?).to be_falsey
      end
    end

    context 'owned by corporation' do
      let(:corporation) { double('Corporation', is_a?: true)}

      it 'should be true if corporation has more than one company' do
        allow(corporation).to receive(:companies).and_return([subject, subject])
        subject.owner = corporation
        expect(subject.can_be_sold?).to be_truthy
      end

      it 'should be false if corporation has one company' do
        allow(corporation).to receive(:companies).and_return([subject])
        subject.owner = corporation
        expect(subject.can_be_sold?).to be_falsey
      end
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
