module PoParser
  COMMENTS_LABELS = {
    :translator_comment => '#',
    :refrence => '#:',
    :extracted_comment => '#.',
    :flag => '#,',
    :previous_untraslated_string => '#|',
  }

  ENTRIES_LABELS = {
    :msgid => 'msgid',
    :msgid_plural => 'msgid_plural',
    :msgstr => 'msgstr',
    :msgstr_plural => 'msgstr_plural',
    :msgctxt => 'msgctxt'
  }

  LABELS = COMMENTS_LABELS.merge(ENTRIES_LABELS).keys
end
