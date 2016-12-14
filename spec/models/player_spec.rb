require './spec/spec_helper'

describe Player do
  subject { Player.new 1, 'TestUser' }
  let(:company) { Company.new subject, *(['BSE'].concat Company::COMPANIES['BSE']) }

  describe '#value' do
    it 'should add up everything' do
      subject.companies << company
      expect(subject.value).to eq(30 + company.value)
    end
  end

end
