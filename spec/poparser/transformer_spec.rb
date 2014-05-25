# encoding: utf-8
require "spec_helper"

describe PoParser::Transformer do
  let(:trans){ PoParser::Transformer.new }

  it 'transforms the returned array from parslet to a usable hash' do
    parslet_array = [{:translator_comment=>"Persian translation\n"}, {:translator_comment=>"Copyright\n"}, {:msgid=>"\"test\"\n"}]
    transformed_hash = {:translator_comment=>["Persian translation\n", "Copyright\n"], :msgid=>"\"test\"\n"}
    expect(trans.transform(parslet_array)).to eq(transformed_hash)
  end

  it 'transforms plural msgstr forms correctly' do
    data = [{:msgstr_plural=>{:plural_id=>"0", :text=>"this is a txt"}}]
    result = { :'msgstr[0]' => "this is a txt" }
    expect(trans.transform(data)).to eq(result)
  end

  it 'transforms multiline plural msgstr forms correctly' do
    data = [{:msgstr_plural=>[{:plural_id=>"0", :text=>"this is a txt"}, {:text => 'some text'}]}]
    result = { :'msgstr[0]' => ["this is a txt", "some text"] }
    expect(trans.transform(data)).to eq(result)
  end
end
