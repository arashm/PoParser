require 'spec_helper'

describe PoParser::Entry do
  before(:each) do
    @entry = PoParser::Entry.new
  end

  let(:labels) do
    %i(refrence extracted_comment flag previous_untraslated_string translator_comment
      msgid msgid_plural msgstr msgctxt)
  end

  it 'should respond to labels' do
    labels.each do |label|
      @entry.should respond_to label
    end
  end

  it 'should show a hash presentation of a entry' do
    @entry.msgid = 'string'
    @entry.msgstr = 'reshte'
    expect(@entry.to_h).to eq({:msgid=>"string", :msgstr=>"reshte"})
  end

  it 'should translate the entry' do
    @entry.translate ('this entry is translated')
    expect(@entry.msgstr.to_s).to eq 'this entry is translated'
  end

  it 'checks if the entry is translated' do
    expect(@entry.translated?).to be_false
    @entry.translate ''
    expect(@entry.translated?).to be_false
    @entry.translate 'translated'
    expect(@entry.complete?).to be_true
  end

  context 'Plural' do
    it 'returns false if it\'s not plural' do
      expect(@entry.plural?).to be_false
    end

    it 'returns true if it\'s plural' do
      @entry.msgid_plural = 'sth'
      expect(@entry.plural?).to be_true
    end
  end

  context 'Flags' do
    it 'should check if a entry is fuzzy' do
      expect(@entry.fuzzy?).to be_false
      @entry.flag = 'fuzzy'
      expect(@entry.fuzzy?).to be_true
    end

    it 'should flag a entry as fuzzy' do
      expect(@entry.flag_as_fuzzy).to be_true
      expect(@entry.flag).to eq('fuzzy')
    end

    it 'should be able to set a custome flag' do
      expect(@entry.flag_as 'python-format').to be_true
      expect(@entry.flag).to eq('python-format')
    end
  end

  context 'Convertion to string' do
    it 'should be able to show string representaion of entries' do
      @entry.flag = 'fuzzy'
      @entry.msgid = 'string'
      @entry.msgstr = 'reshte'
      result = "#, fuzzy\nmsgid \"string\"\nmsgstr \"reshte\"\n"
      expect(@entry.to_s).to eq result
    end

    it 'convert multiline entries to string' do
      @entry.flag = 'fuzzy'
      @entry.msgid = ['first line', 'second line']
      @entry.msgstr = ['first line', 'second line']
      result = "#, fuzzy\nmsgid \"\"\n\"first line\"\n\"second line\"\nmsgstr \"\"\n\"first line\"\n\"second line\"\n"
      expect(@entry.to_s).to eq(result)
    end
  end
end
