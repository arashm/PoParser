# encoding: utf-8
require 'spec_helper'

describe PoParser::Po do
  let (:entry) do 
    {
      translator_comment: 'comment',
      refrence: 'refrence comment',
      msgid: 'untranslated',
      msgstr: 'translated string'
    }
  end
  
  before(:each) do
    @po = PoParser::Po.new
  end

  it 'should be able to add an entry to Po' do
    # << is an alias for Po#add_entry
    expect(@po << entry).to be_a_kind_of PoParser::Entry
  end

  it 'should be able to add multiple entries' do
    entries = [entry, entry.dup]
    expect(@po << entries).to be_a_kind_of Array
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

  it 'shows stats' do
    entry2, entry3 = entry.dup, entry.dup
    [entry2, entry3].each { |en| en[:msgstr] = '' }
    @po << [entry, entry2, entry3]
    ap @po.stats
  end
end
