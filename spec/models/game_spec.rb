require './spec/spec_helper'

describe RollingStock do
  subject { create :game }
  it 'should init' do
    game = create :game
    expect(game).not_to be_nil
  end

  describe '#issue_share' do
    context 'with valid corportation' do
      it 'should issue a share' do
        subject.issue_share 'Android'
      end
    locations = e:locations_csv]nd

    if locations
    end

  end

end
