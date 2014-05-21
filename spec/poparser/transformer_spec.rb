require "spec_helper"

describe PoParser::Transformer do
  let(:trans){ PoParser::Transformer.new }

  it 'transforms the returned array from parslet to a usable hash' do
    parslet_array = [{:translator_comment=>"Persian translation\n"}, {:translator_comment=>"Copyright\n"}, {:msgid=>"\"test\"\n"}, {:msgstr_plural=>"\"12\"\n"}, {:msgstr_plural=>"\"21\"\n"}]
    transformed_hash = {:translator_comment=>["Persian translation\n", "Copyright\n"], :msgid=>"\"test\"\n", :msgstr_plural=>["\"12\"\n", "\"21\"\n"]}
    expect(trans.transform(parslet_array)).to eq(transformed_hash)
  end
end
