# encoding: utf-8
require 'spec_helper'

describe PoParser::Message do
  it 'converts the message to string' do
    message = PoParser::Message.new(:msgid, "this is a line")
    result = "msgid \"this is a line\"\n"
    expect(message.to_s(true)).to eq(result)
  end

  it 'converts array of same message to string' do
    message = PoParser::Message.new(:msgid, ["this is a line", "this is another line"])
    result = "msgid \"\"\n\"this is a line\"\n\"this is another line\"\n"
    expect(message.to_s(true)).to eq(result)
  end

  it 'shows one line string for multiline entries' do
    message = PoParser::Message.new(:msgid, ["", "this is a line ", "this is another line"])
    result = "this is a line this is another line"
    expect(message.str).to eq result
  end

  it 'converts plural msgstr correctly' do
    message = PoParser::Message.new(:"msgstr[0]", "this is a line")
    result = "msgstr[0] \"this is a line\"\n"
    expect(message.to_s(true)).to eq(result)
  end

  it 'converts multiline plural msgstr correctly' do
    message = PoParser::Message.new(:"msgstr[0]", ["this is a line", "this is another line"])
    result = "msgstr[0] \"\"\n\"this is a line\"\n\"this is another line\"\n"
    expect(message.to_s(true)).to eq(result)
  end
end
