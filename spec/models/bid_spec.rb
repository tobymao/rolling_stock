require './spec/spec_helper'

describe Bid do
  let(:player) { Player.new 1, 'Test' }
  let(:company) { Company.all['BME'].dup }
  subject { Bid.new player, company, 10 }


  describe '#initialize' do
    it 'should provision variables' do
      expect(subject).not_to be_nil
    end
  end

end
