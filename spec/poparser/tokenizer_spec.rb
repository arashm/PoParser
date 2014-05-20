require "spec_helper.rb"

describe PoParser::Tokenizer do
  let(:token)  { PoParser::Tokenizer.new }
  let(:po_file){ Pathname.new('spec/poparser/fixtures/tokenizer.po').realpath }
  let(:result) { [{:refrence=>"templates:105", :msgid=>"Afrikaans", :msgstr=>"آفریقایی"}, {:flag=>"fuzzy", :msgid=>"Afrikaans"}] }

  it 'should be able to extracts entries' do
    expect(
      token.extract_entries(po_file).to_h
    ).to eq(result)
  end

  # it 's cool' do
  #   po_file2 = Pathname.new('spec/poparser/fixtures/multiline.po').realpath
  #   token.extract_entries(po_file2).entries.each do |entry|
  #     ap entry.to_h
  #     ap entry.to_s
  #   end
  # end
end
