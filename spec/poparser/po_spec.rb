# encoding: utf-8
require 'spec_helper'

describe PoParser::Po do
  let (:entry) do
    {
      translator_comment: 'comment',
      reference: 'reference comment',
      msgid: 'untranslated',
      msgstr: 'translated string'
    }
  end

  before(:each) do
    @po = PoParser::Po.new
  end

  it 'should be able to add an entry to Po' do
    # << is an alias for Po#add
    expect(@po << entry).to be_a_kind_of PoParser::Po
  end

  it 'should be able to add multiple entries' do
    entries = [entry, entry.dup]
    expect(@po << entries).to be_a_kind_of PoParser::Po
  end

  it 'returns all fuzzy entries' do
    entry2, entry3 = entry.dup, entry.dup
    [entry2, entry3].each { |en| en[:flag] = 'fuzzy' }
    @po << [entry, entry2, entry3]
    expect(@po.fuzzy.size).to eq 2
  end

  it 'returns all untraslated strings' do
    entry2, entry3 = entry.dup, entry.dup
    [entry2, entry3].each { |en| en[:msgstr] = '' }
    @po << [entry, entry2, entry3]
    expect(@po.untranslated.size).to eq 2
  end

  it 'returns all obsolete strings' do
    entry2, entry3 = entry.dup, entry.dup
    [entry2, entry3].each { |en| en[:obsolete] = ['msgid "test"', 'msgstr "test"'] }
    @po << [entry, entry2, entry3]
    expect(@po.obsolete.size).to eq 2
  end

  it 'shows stats' do
    entry2, entry3, entry4 = entry.dup, entry.dup, entry.dup
    [entry2, entry3].each { |en| en[:msgstr] = '' }
    @po << [entry, entry2, entry3, entry4]
    @po.entries.last.flag_as_fuzzy
    result = @po.stats

    expect(result[:translated]).to eq 25
    expect(result[:untranslated]).to eq 50
    expect(result[:fuzzy]).to eq 25
  end

  it 'shouldn\'t count obsolete entries' do
    @po << entry
    obsolete = { obsolete: ['msgid "sth"', 'msgstr "sth"'], flag: 'Fuzzy' }
    @po << obsolete
    expect(@po.size).to eq(1)
  end

  context 'search' do
    before do
      path = Pathname.new('spec/poparser/fixtures/test.po').realpath
      @po = PoParser::Tokenizer.new.extract_entries(path)
    end

    it 'raises error if label is not valid' do
      expect{
        @po.search_in(:wrong, 'sth')
      }.to raise_error(ArgumentError, 'Unknown key: wrong')
    end

    it 'searches in PO file' do
      result = @po.search_in(:msgid, 'Invalid action')
      expect(result.length).to eq(1)
      expect(result[0].msgid.str).to eq('Invalid action. Someone probably posted another action just before you.')
    end
  end

  context 'Header' do
    before do
      path = Pathname.new('spec/poparser/fixtures/header.po').realpath
      @po = PoParser::Tokenizer.new.extract_entries(path)
    end

    it 'should respond to header' do
      expect(@po).to respond_to :header
    end

    it 'should recognize header' do
      expect(@po.header).to be_a_kind_of PoParser::Header
    end

    it 'should have right content for header' do
      expect(@po.header.comments).to eq(["Arash Mousavi <mousavi.arash@gmail.com>, 2014.", ""])
    end

    it 'should parse the flag and be fuzzy' do
      expect(@po.header.flag.to_s).to eq('fuzzy')
      expect(@po.header.fuzzy?).to eq(true)
    end

    it 'should flag a entry as fuzzy' do
      expect(@po.header.flag_as_fuzzy).to be_truthy
      expect(@po.header.flag).to eq('fuzzy')
    end

    it 'should be able to set a custome flag' do
      expect(@po.header.flag_as 'python-format').to be_truthy
      expect(@po.header.flag).to eq('python-format')
    end

    it 'throws error if there\'re two header string' do
      path = Pathname.new('spec/poparser/fixtures/header_error.po').realpath
      expect{
        @po = PoParser::Tokenizer.new.extract_entries(path)
        }.to raise_error(RuntimeError, "Duplicate entry, header was already instantiated")
    end
  end

end
