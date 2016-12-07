require './spec/spec_helper'

describe User do
  subject { create :user }

  describe '#password=' do
    it 'should provide encrypted password' do
      expect(subject.password= "somepassword").not_to be_nil
    end
  end

end
