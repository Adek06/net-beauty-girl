require 'spec_helper'

RSpec.describe App do
  let(:app) { App.new }

  describe 'GET /' do
    context 'get index' do
      let(:response) { get '/' }
      it 'abc' do
        expect(response.status).to eq 200
      end
    end
  end
end
