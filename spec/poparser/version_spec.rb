require 'spec_helper'

# Just as test to ensure that test suit is working correctly
describe 'Version' do
  it 'shows the version correctly' do
    expect(PoParser::VERSION).to eq('0.0.1')
  end
end
