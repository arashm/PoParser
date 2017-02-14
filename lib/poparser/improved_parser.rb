module PoParser
  class ImprovedParser < Parslet::Parser
    require 'parslet/accelerator'
    A = Accelerator

    root(:document)

    rule(:document) { comment.repeat >> entry.repeat }

    rule(:comment)  { str('#') >> comments }
    rule(:entry)    { str('msg') >> entries }
    # Comments
    rule(:comments) do
      reference.as(:reference) |
      extracted_comment.as(:extracted_comment) |
      flag.as(:flag) |
      previous |
      obsolete.as(:obsolete) |
      translator_comment.as(:translator_comment)
    end

    rule(:translator_comment)       { space?  >> comment_text_line }
    rule(:extracted_comment)        { spaced('.') >> comment_text_line }
    rule(:reference)                { spaced(':') >> comment_text_line }
    rule(:flag)                     { spaced(',') >> comment_text_line }
    rule(:previous)                 { str('| msg') >> (
                                        previous_msgctxt.as(:previous_msgctxt) |
                                        previous_msgid.as(:previous_msgid) |
                                        previous_msgid_plural.as(:previous_msgid_plural)
                                        )
                                    }
    rule(:previous_msgctxt)         { spaced('ctxt') >> msg_text_line >> previous_multiline.repeat }
    rule(:previous_msgid)           { spaced('id') >> msg_text_line >> previous_multiline.repeat }
    rule(:previous_msgid_plural)    { spaced('id_plural') >> msg_text_line >> previous_multiline.repeat }
    rule(:obsolete)                   { spaced('~') >> comment_text_line }

    rule(:previous_multiline)       { spaced('#|') >> msg_text_line }

    # Entries
    rule(:entries) do
      msgid.as(:msgid) |
      msgid_plural.as(:msgid_plural) |
      msgstr.as(:msgstr) |
      msgstr_plural.as(:msgstr_plural) |
      msgctxt.as(:msgctxt)
    end

    rule(:multiline)    { str('"').present? >> msg_text_line.repeat }
    rule(:msgid)        { spaced('id') >> msg_text_line >> multiline.repeat }
    rule(:msgid_plural) { spaced('id_plural') >> msg_text_line >> multiline.repeat }

    rule(:msgstr)       { spaced('str') >> msg_text_line >> multiline.repeat }
    rule(:msgstr_plural){ str('str') >> bracketed(match["[0-9]"].as(:plural_id)) >> space? >> msg_text_line >> multiline.repeat }
    rule(:msgctxt)      { spaced('ctxt') >> msg_text_line >> multiline.repeat }

    # Helpers
    rule(:space)       { match['\p{Blank}'] } #match only whitespace and not newline
    rule(:space?)      { space.repeat }
    rule(:newline)     { match["\n"] }
    rule(:eol)         { newline | any.absent? }
    rule(:character)   { escaped | text }
    rule(:text)        { any }
    rule(:escaped)     { str('\\') >> any }
    rule(:msg_line_end){ str('"') >> space? >> eol }

    rule(:comment_text_line) do
      (eol.absent? >> character).repeat.as(:text) >> eol
    end

    rule(:msg_text_line) do
      str('"') >> (str('"').absent? >> character).repeat.as(:text) >> msg_line_end
    end

    def bracketed(atom)
      str('[') >> atom >> str(']')
    end

    def spaced(character)
      str(character) >> space?
    end

    def optimize
      A.apply(self,
        A.rule(
        (A.str(:x).absent? >> ((A.str('\\') >> A.any) | A.any)).repeat
        ){ GobbleUp.new(x) }
      )
    end

  end
end
