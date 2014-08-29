# encoding: utf-8
require 'spec_helper'

describe PoParser::Header do
  let(:entry) do
    {translator_comment: ["Persian translation for gnome-shell-extensions.", "Copyright (C) 2011 Iranian Free Software Users Group (IFSUG.org) translation team.", "This file is distributed under the same license as the gnome-shell-extensions package.", "Arash Mousavi <mousavi.arash@gmail.com>, 2011, 2013, 2014.", ""],
    msgstr: ["Project-Id-Version: gnome-shell-extensions gnome-3-0\\n", "Report-Msgid-Bugs-To: http://bugzilla.gnome.org/enter_bug.cgi?product=gnome-", "shell&keywords=I18N+L10N&component=extensions\\n", "POT-Creation-Date: 2014-08-28 07:40+0000\\n", "PO-Revision-Date: 2014-08-28 19:59+0430\\n", "Last-Translator: Arash Mousavi <mousavi.arash@gmail.com>\\n", "Language-Team: Persian <>\\n", "Language: fa_IR\\n", "MIME-Version: 1.0\\n", "Content-Type: text/plain; charset=UTF-8\\n", "Content-Transfer-Encoding: 8bit\\n", "X-Poedit-SourceCharset: utf-8\\n", "X-Generator: Gtranslator 2.91.6\\n", "Plural-Forms: nplurals=1; plural=0;\\n"]}
  end

  let(:comment) do
    "Persian translation for gnome-shell-extensions.\nCopyright (C) 2011 Iranian Free Software Users Group (IFSUG.org) translation team.\nThis file is distributed under the same license as the gnome-shell-extensions package.\nArash Mousavi <mousavi.arash@gmail.com>, 2011, 2013, 2014.\n"
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
      @header.should respond_to label
    end
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

end
