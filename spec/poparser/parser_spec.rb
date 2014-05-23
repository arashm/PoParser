require "spec_helper"

describe PoParser::Parser do
  let(:po) { PoParser::Parser.new }

  context(:comments) do

    let(:tc)  { po.translator_comment }
    let(:rc)  { po.refrence }
    let(:ec)  { po.extracted_comment }
    let(:fc)  { po.flag }
    let(:pusc){ po.previous_untraslated_string }

    it 'parses the translator comment' do
      tc.should parse("# Persian translation for damned-lies 123123\n")
      tc.should parse("# Copyright (C) 2012 damned-lies's COPYRIGHT HOLDER\n")
      tc.should parse("# Arash Mousavi <mousavi.arash@gmail.com>, 2014.\n")
    end

    it 'parses refrence comment' do
      rc.should parse("#: database-content.py:1 database-content.py:129 settings.py:52\n")
    end

    it 'parses extracted_comment' do
      ec.should parse("#. database-content.py:1 database-content.py:129 settings.py:52\n")
    end

    it 'parses flag_comment' do
      fc.should parse("#, python-format\n")
    end

    it 'parses previous_untraslated_string' do
      pusc.should parse("#| msgid \"\"\n")
      pusc.should parse("#| \"Hello,\\n\"\n")
      pusc.should parse("#| \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is \"\n")
    end

  end

  context 'Entries' do
    let(:msgid) { po.msgid }
    let(:msgstr){ po.msgstr }
    let(:pofile){ Pathname.new('spec/poparser/fixtures/multiline.po').realpath }

    it 'parses msgid' do
      msgid.should parse "msgid \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
      msgid.should parse "msgid \"The new \"state\" of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
    end

    it 'parses msgstr' do
      msgstr.should parse "msgstr \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
      msgstr.should parse "msgstr \"فعالیت نامعتبر. شاید یک نفر دیگر دقیقا قبل از شما یک فعالیت دیگر ارسال کرده ۱۲۳۱۲۳۱safda \"\n"
    end

    it 'parses multiline entries' do
      data = pofile.read
      result = [{:msgid=>[{:text=>""}, {:text=>"first"}, {:text=>"second"}]}, {:msgstr=>[{:text=>""}, {:text=>"aval"}, {:text=>"dovom"}]}]
      expect(po.parse data).to eq(result)
    end

    it 'parses plural msgstr entries' do
      str = "msgstr[0] \"\""
      result = [{:msgstr_plural=>{:plural_id=>"0", :text=>""}}]
      expect(po.parse(str)).to eq(result)
    end
  end

end
