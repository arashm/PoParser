require "spec_helper.rb"

describe PoParser::Tokenizer do
  let(:token) { PoParser::Tokenizer.new }
  let(:po_file) { Pathname.new('spec/poparser/fixtures/tokenizer.po').realpath }
  let(:result) { [{:refrence=>"templates:105", :msgid=>"Afrikaans", :msgstr=>"آفریقایی"}, {:flag=>"fuzzy", :msgid=>"Afrikaans"}] }

  it 'should be able to extracts entries' do
    expect(
      token.extract_entries(po_file).to_h
    ).to eq result
  end
end
