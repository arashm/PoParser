module PoParser
  COMMENTS_LABELS = {
    :translator_comment => '#',
    :extracted_comment => '#.',
    :refrence => '#:',
    :flag => '#,',
    :previous_untraslated_string => '#|',
    :cached => '#~'
  }

  ENTRIES_LABELS = {
    :msgctxt => 'msgctxt',
    :msgid => 'msgid',
    :msgid_plural => 'msgid_plural',
    :msgstr => 'msgstr'
  }

  LABELS = COMMENTS_LABELS.merge(ENTRIES_LABELS).keys

  HEADER_LABELS = {
    :pot_creation_date => "POT-Creation-Date",
    :po_revision_date => "PO-Revision-Date",
    :project_id => "Project-Id-Version",
    :report_to => "Project-Id-Version",
    :last_translator => "Last-Translator",
    :team => "Language-Team",
    :language => "Language",
    :charset => "Content-Type",
    :encoding => "Content-Transfer-Encoding",
    :plural_forms => "Plural-Forms"
  }
end
