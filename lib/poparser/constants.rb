# frozen_string_literal: true

module PoParser
  COMMENTS_LABELS = {
    translator_comment: '#',
    extracted_comment: '#.',
    reference: '#:',
    flag: '#,',
    previous_msgctxt: '#| msgctxt',
    previous_msgid: '#| msgid',
    previous_msgid_plural: '#| msgid_plural',
    obsolete: '#~',
  }.freeze

  ENTRIES_LABELS = {
    msgctxt: 'msgctxt',
    msgid: 'msgid',
    msgid_plural: 'msgid_plural',
    msgstr: 'msgstr',
  }.freeze

  LABELS = COMMENTS_LABELS.merge(ENTRIES_LABELS).keys

  HEADER_LABELS = {
    pot_creation_date: 'POT-Creation-Date',
    po_revision_date: 'PO-Revision-Date',
    project_id: 'Project-Id-Version',
    report_to: 'Report-Msgid-Bugs-To',
    last_translator: 'Last-Translator',
    team: 'Language-Team',
    language: 'Language',
    charset: 'Content-Type',
    encoding: 'Content-Transfer-Encoding',
    plural_forms: 'Plural-Forms',
  }.freeze
end
