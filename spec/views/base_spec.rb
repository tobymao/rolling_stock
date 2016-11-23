require './spec/spec_helper'

describe Views::Base do
  it 'should render' do
    expect(Base.new).not_to be_nil
  end
end
