# encoding: utf-8
require 'spec_helper'

describe PoParser::Header do
  let(:entry) do
    {translator_comment: ["Persian translation for gnome-shell-extensions.", "Copyright (C) 2011 Iranian Free Software Users Group (IFSUG.org) translation team.", "This file is distributed under the same license as the gnome-shell-extensions package.", "Arash Mousavi <mousavi.arash@gmail.com>, 2011, 2013, 2014.", ""],
    msgstr: ["Project-Id-Version: gnome-shell-extensions gnome-3-0\\n", "Report-Msgid-Bugs-To: http://bugzilla.gnome.org/enter_bug.cgi?product=gnome-", "shell&keywords=I18N+L10N&component=extensions\\n", "POT-Creation-Date: 2014-08-28 07:40+0000\\n", "PO-Revision-Date: 2014-08-28 19:59+0430\\n", "Last-Translator: Arash Mousavi <mousavi.arash@gmail.com>\\n", "Language-Team: Persian <>\\n", "Language: fa_IR\\n", "MIME-Version: 1.0\\n", "Content-Type: text/plain; charset=UTF-8\\n", "Content-Transfer-Encoding: 8bit\\n", "X-Poedit-SourceCharset: utf-8\\n", "X-Generator: Gtranslator 2.91.6\\n", "Plural-Forms: nplurals=1; plural=0;\\n"]}
  end

  let(:labels) {
    [
      :pot_creation_date, :po_revision_date, :project_id,
      :report_to, :last_translator, :team, :language, :charset,
      :encoding, :plural_forms
    ]
  }

  before {
    @entry = PoParser::Entry.new(entry)
    @header = PoParser::Header.new(@entry)
  }

  it 'should respond to labels' do
    labels.each do |label|
      expect(@header).to respond_to label
    end
  end

  it 'returns correct values for labels' do
    expect(@header.project_id).to eq('gnome-shell-extensions gnome-3-0')
    expect(@header.report_to).to eq('http://bugzilla.gnome.org/enter_bug.cgi?product=gnome-shell&keywords=I18N+L10N&component=extensions')
    expect(@header.report_msgid_bugs_to).to eq('http://bugzilla.gnome.org/enter_bug.cgi?product=gnome-shell&keywords=I18N+L10N&component=extensions')
    expect(@header.pot_creation_date).to eq('2014-08-28 07:40+0000')
    expect(@header.po_revision_date).to eq('2014-08-28 19:59+0430')
    expect(@header.last_translator).to eq('Arash Mousavi <mousavi.arash@gmail.com>')
    expect(@header.team).to eq('Persian <>')
    expect(@header.language).to eq('fa_IR')
    expect(@header.charset).to eq('text/plain; charset=UTF-8')
    expect(@header.encoding).to eq('8bit')
    expect(@header.plural_forms).to eq('nplurals=1; plural=0;')
  end

  it 'should convert configs to hash' do
    expect(@header.original_configs).to eq(
      {"Project-Id-Version"=>"gnome-shell-extensions gnome-3-0", "Report-Msgid-Bugs-To"=>"http://bugzilla.gnome.org/enter_bug.cgi?product=gnome-shell&keywords=I18N+L10N&component=extensions", "POT-Creation-Date"=>"2014-08-28 07:40+0000", "PO-Revision-Date"=>"2014-08-28 19:59+0430", "Last-Translator"=>"Arash Mousavi <mousavi.arash@gmail.com>", "Language-Team"=>"Persian <>", "Language"=>"fa_IR", "MIME-Version"=>"1.0", "Content-Type"=>"text/plain; charset=UTF-8", "Content-Transfer-Encoding"=>"8bit", "X-Poedit-SourceCharset"=>"utf-8", "X-Generator"=>"Gtranslator 2.91.6", "Plural-Forms"=>"nplurals=1; plural=0;"}
    )
  end

  it 'always should show the updated hash of configs' do
    @header.language = 'en_US'
    expect(@header.configs['Language']).to eq('en_US')
  end

  context 'Comments' do
    it 'should handle single line comments' do
      @header.comments = "This is the header"
      expect(@header.to_s).to start_with("# This is the header\nmsgid")
    end

    it 'should handle single multiline comments' do
      @header.comments = ["This is a header", "with two lines"]
      expect(@header.to_s).to start_with("# This is a header\n# with two lines\nmsgid")
    end
  end

  context 'Flags' do
    it 'should check if a entry is fuzzy' do
      expect(@header.fuzzy?).to be_falsy
      @header.flag_as('fuzzy')
      expect(@header.fuzzy?).to be_truthy
    end

    it 'should flag a entry as fuzzy' do
      expect(@header.flag_as_fuzzy).to be_truthy
      expect(@header.flag).to eq('fuzzy')
    end

    it 'should be able to set a custome flag' do
      expect(@header.flag_as 'python-format').to be_truthy
      expect(@header.flag).to eq('python-format')
    end
  end

end
