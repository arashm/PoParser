# encoding: utf-8
require "spec_helper.rb"

describe PoParser::Tokenizer do
  let(:token)  { PoParser::Tokenizer.new(true) }
  let(:po_file){ Pathname.new('spec/poparser/fixtures/tokenizer.po').realpath }
  let(:po_file_empty_line){ Pathname.new('spec/poparser/fixtures/tokenizer_empty_line.po').realpath }
  let(:result) { [{:reference=>"templates:105", :msgid=>"Afrikaans", :msgstr=>"آفریقایی"}, {:flag=>"fuzzy", :msgid=>"Afrikaans", :msgstr=>"آفریقایی" }] }

  it 'should be able to extracts entries' do
    expect(token.extract(po_file).to_h).to eq(result)
  end

  it 'should gracefully handle empty lines at the beginning' do
    expect(
      token.extract(po_file_empty_line).to_h
    ).to eq(result)
  end
end
