module PoParser
  class Parser < Parslet::Parser
    root(:document)

    rule(:document) { lines.repeat }
    rule(:lines)    { comments | entries }

    # Comments
    rule(:comments) do
      reference.as(:reference) |
      extracted_comment.as(:extracted_comment) |
      flag.as(:flag) |
      previous_msgctxt.as(:previous_msgctxt) |
      previous_msgid.as(:previous_msgid) |
      previous_msgid_plural.as(:previous_msgid_plural) |
      obsolete.as(:obsolete) |
      translator_comment.as(:translator_comment)
    end

    rule(:translator_comment)       { spaced('#') >> comment_text_line }
    rule(:extracted_comment)        { spaced('#.') >> comment_text_line }
    rule(:reference)                { spaced('#:') >> comment_text_line }
    rule(:flag)                     { spaced('#,') >> comment_text_line }
    rule(:previous_msgctxt)         { spaced('#| msgctxt') >> msg_text_line >> previous_multiline.repeat }
    rule(:previous_msgid)           { spaced('#| msgid') >> msg_text_line >> previous_multiline.repeat }
    rule(:previous_msgid_plural)    { spaced('#| msgid_plural') >> msg_text_line >> previous_multiline.repeat }
    rule(:obsolete)                 { spaced('#~') >> comment_text_line }

    rule(:previous_multiline)       { previous_multiline_start.present? >> spaced('#|') >> msg_text_line.repeat.maybe }
    rule(:previous_multiline_start) { spaced('#|') >> str('"') }

    # Entries
    rule(:entries) do
      msgid.as(:msgid) |
      msgid_plural.as(:msgid_plural) |
      msgstr.as(:msgstr) |
      msgstr_plural.as(:msgstr_plural) |
      msgctxt.as(:msgctxt)
    end

    rule(:multiline)    { str('"').present? >> msg_text_line.repeat.maybe }
    rule(:msgid)        { spaced('msgid') >> msg_text_line >> multiline.repeat }
    rule(:msgid_plural) { spaced('msgid_plural') >> msg_text_line >> multiline.repeat }

    rule(:msgstr)       { spaced('msgstr') >> msg_text_line >> multiline.repeat }
    rule(:msgstr_plural){ str('msgstr') >> bracketed(match["[0-9]"].as(:plural_id)) >> space? >> msg_text_line >> multiline.repeat }
    rule(:msgctxt)      { spaced('msgctxt') >> msg_text_line >> multiline.repeat }

    # Helpers
    rule(:space)       { match['\p{Blank}'].repeat } #match only whitespace and not newline
    rule(:space?)      { space.maybe }
    rule(:newline)     { match["\n"] }
    rule(:eol)         { newline | any.absent? }
    rule(:character)   { escaped | text }
    rule(:text)        { any }
    rule(:escaped)     { str('\\') >> any }
    rule(:msg_line_end){ str('"') >> space? >> eol }

    rule(:comment_text_line) do
      (eol.absent? >> character).repeat.maybe.as(:text) >> eol
    end

    rule(:msg_text_line) do
      str('"') >> (msg_line_end.absent? >> character).repeat.maybe.as(:text) >> msg_line_end
    end

    def bracketed(atom)
      str('[') >> atom >> str(']')
    end

    def spaced(character)
      str(character) >> space?
    end
  end
end
