require "spec_helper.rb"

describe PoParser::Tokenizer do
  let(:token) { PoParser::Tokenizer.new }

  it 'extracts blocks' do
    result = [{:refrence=>"templates:105", :msgid=>"\"Afrikaans\"", :msgstr=>"\"آفریقایی\"", :id=>1}, {:flag=>"fuzzy", :msgid=>"\"Afrikaans\"", :id=>2}]
    expect(
      token.extract_blocks Pathname.new('spec/poparser/fixtures/tokenizer.po').realpath
    ).to eq result
  end
end
