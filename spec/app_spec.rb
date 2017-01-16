require './spec/spec_helper'

describe RollingStock do
  let(:app) { RollingStock.freeze.app }

  describe 'get requests' do
    %w[/ signup login].each do |path|
      it "#{path} should return 200" do
        get path
        expect(last_response).to be_ok
      end
    end
  end

end
