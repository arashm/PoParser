# encoding: utf-8
require "spec_helper"

describe PoParser do
  let(:po_file) { Pathname.new('spec/poparser/fixtures/tokenizer.po').realpath }
  let(:po_file_content) { File.read('spec/poparser/fixtures/tokenizer.po') }
  let(:header_fixture) { Pathname.new('spec/poparser/fixtures/header.po').realpath }
  let(:multiline_fixture) { Pathname.new('spec/poparser/fixtures/multiline.po').realpath }
  let(:plural_fixture) { Pathname.new('spec/poparser/fixtures/plural.po').realpath }
  let(:test_fixture) { Pathname.new('spec/poparser/fixtures/test.po').realpath }

  it 'parses a file' do
    expect(PoParser.parse(po_file)).to be_a_kind_of PoParser::Po
  end

  it 'should print deprecation warning when passing file to parse' do
    expect(Kernel).to receive(:warn).with(
      'DEPRICATION WARNING: `parse` only accepts content of a PO '\
      'file as a string and this behaviour will be removed on next major '\
      'release. Use `parse_file` instead.'
    ).once

    PoParser.parse(po_file)
  end

  it 'parses a payload' do
    expect(PoParser.parse(po_file_content)).to be_a_kind_of PoParser::Po
  end

  it 'correclty parses header fixture' do
    entry = PoParser::Entry.new(
    {
      :translator_comment => [
        "Arash Mousavi <mousavi.arash@gmail.com>, 2014.",
        ""],
      :flag => "fuzzy",
      :msgid => "",
      :msgstr => [
        "",
        "Project-Id-Version: damned-lies master\\n",
        "Report-Msgid-Bugs-To: \\n"]
      })
    expected_result = PoParser::Header.new(entry)
    expect(PoParser.parse(header_fixture).header.inspect).to eql(expected_result.inspect)
  end

  it 'correclty parses multiline fixture' do
    expected_result = PoParser::Entry.new(
    {
      :msgid => [
        "",
        "first",
        "second"],
      :msgstr => [
        "",
        "aval",
        "dovom"]
      })
    expect(PoParser.parse(multiline_fixture).entries[0].inspect).to eq(expected_result.inspect)
  end

  it 'correclty parses plural fixture' do
    expected_result = PoParser::Entry.new(
    {
      :msgid => " including <a href=\\\"%(img_url)s\\\">%(stats)s image</a>",
      :msgid_plural => " including <a href=\\\"%(img_url)s\\\">%(stats)s images</a>",
      "msgstr[0]" => [
        "",
        "sad ads fdsaf ds fdfs dsa "
      ],
      "msgstr[1]" => [
        "",
        "sad ads fdsaf ds fdfs dsa "
      ]
      })
    expect(PoParser.parse(plural_fixture).entries[0].inspect).to eq(expected_result.inspect)
  end

  it 'correclty parses test fixture' do
    expected_result = PoParser::Po.new
    expected_result << { :translator_comment => [
        "Persian translation for damned-lies.",
        "Copyright (C) 2012 damned-lies's COPYRIGHT HOLDER",
        "This file is distributed under the same license as the damned-lies package.",
        "Arash Mousavi <mousavi.arash@gmail.com>, 2014.",
        ""
      ],
      :msgid => "",
      :msgstr => [
        "",
        "Project-Id-Version: damned-lies master\\n",
        "Report-Msgid-Bugs-To: \\n",
        "POT-Creation-Date: 2012-05-04 12:56+0000\\n",
        "PO-Revision-Date: 2014-05-15 22:24+0330\\n",
        "Last-Translator: Arash Mousavi <mousavi.arash@gmail.com>\\n",
        "Language-Team: Persian <fa@li.org>\\n",
        "MIME-Version: 1.0\\n",
        "Content-Type: text/plain; charset=UTF-8\\n",
        "Content-Transfer-Encoding: 8bit\\n",
        "Plural-Forms: nplurals=1; plural=0;\\n",
        "X-Generator: Poedit 1.6.4\\n"
      ]
    }
    expected_result << {
      :reference => "database-content.py:1 database-content.py:129 settings.py:52",
      :msgid => "Afrikaans",
      :msgstr => "آفریقایی"
    }
    expected_result << { :reference => "templates/vertimus/vertimus_detail.html:105",
      :flag => "python-format",
      :msgid => " including <a href=\\\"%(img_url)s\\\">%(stats)s image</a>",
      :msgid_plural => " including <a href=\\\"%(img_url)s\\\">%(stats)s images</a>",
      "msgstr[0]" => "",
      "msgstr[1]" => ""
    }
    expected_result << {
      :reference => "templates/vertimus/vertimus_detail.html:136 vertimus/forms.py:79",
      :msgid => "Invalid action. Someone probably posted another action just before you.",
      :msgstr => [
        "",
        "فعالیت نامعتبر. شاید یک نفر دیگر دقیقا قبل از شما یک فعالیت دیگر ارسال کرده ",
        "است."
      ]
    }
    expected_result << { :reference => "vertimus/models.py:470",
      :flag => "python-format",
      :previous_msgid => [
        "",
        "Hello,\\n",
        "\\n",
        "The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is ",
        "now '%(new_state)s'.\\n",
        "%(url)s\\n",
        "\\n"
      ],
      :msgid => [
        "",
        "The new state of %(module)s - %(branch)s - %(domain)s (%(language)s) is now ",
        "'%(new_state)s'."
      ],
      :msgstr => [
        "",
        "وضعیت جدید %(module)s - %(branch)s - %(domain)s (%(language)s) هم‌اکنون ",
        "«%(new_state)s» است."
      ]
    }
    allow_any_instance_of(PoParser::Header).to receive(:puts)
    expect(PoParser.parse(test_fixture).to_s).to eq(expected_result.to_s)
  end
end
