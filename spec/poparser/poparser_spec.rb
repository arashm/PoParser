# encoding: utf-8
require "spec_helper"

describe PoParser do
  let(:po_file) { Pathname.new('spec/poparser/fixtures/tokenizer.po').realpath }

  it 'parses a file' do
    expect(PoParser.parse(po_file)).to be_a_kind_of PoParser::Po
  end
end
