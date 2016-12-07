# encoding: utf-8
require 'spec_helper'

describe PoParser::Parser do
  let(:po) { PoParser::Parser.new }

  context(:comments) do
    let(:tc)  { po.translator_comment }
    let(:rc)  { po.reference }
    let(:ec)  { po.extracted_comment }
    let(:fc)  { po.flag }
    let(:pusc){ po.previous_untraslated_string }

    it 'parses the translator comment' do
      expect(tc).to parse("# Persian translation for damned-lies 123123\n")
      expect(tc).to parse("# Copyright (C) 2012 damned-lies's COPYRIGHT HOLDER\n")
      expect(tc).to parse("# Arash Mousavi <mousavi.arash@gmail.com>, 2014.\n")
    end

    it 'parses refrence comment' do
      expect(rc).to parse("#: database-content.py:1 database-content.py:129 settings.py:52\n")
    end

    it 'parses extracted_comment' do
      expect(ec).to parse("#. database-content.py:1 database-content.py:129 settings.py:52\n")
    end

    it 'parses flag_comment' do
      expect(fc).to parse("#, python-format\n")
    end

    it 'parses previous_untraslated_string' do
      expect(pusc).to parse("#| msgid \"\"\n")
      expect(pusc).to parse("#| \"Hello,\\n\"\n")
      expect(pusc).to parse("#| \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is \"\n")
    end
  end

  context 'Entries' do
    let(:msgid) { po.msgid }
    let(:msgstr){ po.msgstr }
    let(:pofile){ Pathname.new('spec/poparser/fixtures/multiline.po').realpath }

    it 'parses msgid' do
      expect(msgid).to parse "msgid \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
      expect(msgid).to parse "msgid \"The new \"state\" of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
      expect(msgid).to parse "msgid     \"The new \"state\" of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
    end

    it 'parses msgstr' do
      expect(msgstr).to parse "msgstr \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
      expect(msgstr).to parse "msgstr \"فعالیت نامعتبر. شاید یک نفر دیگر دقیقا قبل از شما یک فعالیت دیگر ارسال کرده ۱۲۳۱۲۳۱safda \"\n"
      expect(msgstr).to parse "msgstr     \"The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is now \"\n"
    end

    it 'parses multiline entries' do
      data = pofile.read
      result = [{:msgid=>[{:text=>""}, {:text=>"first"}, {:text=>"second"}]}, {:msgstr=>[{:text=>""}, {:text=>"aval"}, {:text=>"dovom"}]}]
      expect(po.parse data).to eq(result)
    end

    it 'parses plural msgstr entries' do
      str1 = "msgstr[0] \"\""
      str2 = "msgstr[0]  \"\""
      str3 = "msgstr[0]\"\""
      result = [{:msgstr_plural=>{:plural_id=>"0", :text=>""}}]
      expect(po.parse(str1)).to eq(result)
      expect(po.parse(str2)).to eq(result)
      expect(po.parse(str3)).to eq(result)
    end
  end
end
