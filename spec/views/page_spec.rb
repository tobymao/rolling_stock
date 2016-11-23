require './spec/spec_helper'

describe Views::Page do
  it 'should render' do
    view = Views::Page.new
    expect(view.to_html).not_to be_nil
  end
end
