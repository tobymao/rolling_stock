require './spec/spec_helper'

describe Session do
  subject { create :session }

  describe '#valid?' do
    it 'should return true' do
      expect(subject.valid?).to be(true)
    end
  end

end
