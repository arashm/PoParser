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
end
