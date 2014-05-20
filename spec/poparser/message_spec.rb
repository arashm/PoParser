require 'spec_helper'

describe PoParser::Message do
  it 'converts the message to string' do
    message = PoParser::Message.new(:msgid, "this is a line")
    result = "msgid \"this is a line\"\n"
    expect(message.to_s).to eq(result)
  end

  it 'converts array of same message to string' do
    message = PoParser::Message.new(:msgid, ["this is a line", "this is another line"])
    result = "msgid \"\"\n\"this is a line\"\n\"this is another line\""
    expect(message.to_s).to eq(result)
  end
end
