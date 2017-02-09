module PoParser
  # FastParser directly using Rubys powerful StringScanner (strscan)
  #
  # Important notes about StringScanner.scan:
  # * scan will return nil if there is no match. Using the regex * (zero or more) quantifier will
  #  let scan return an empty string if there is "no match" as the empty string qualifies as
  #  a match of the regex (zero times). We make use of this "trick"
  # * the start of line anchor ^ is obsolete as scan will only match start of line.
  # * rubys regex is by default in single-line mode, therefore scan will only match until
  #  the next newline is hit (unless multi-line mode is explicitly enabled)
  module FastParser
    require_relative 'error'
    require 'strscan'
    extend self

    # parse a single message of the PO format.
    #
    # @param message a single PO message in String format without leading or trailing whitespace
    # @return [Hash] parsed PO message information in Hash format
    def parse(message)
      @result = {}
      @scanner = StringScanner.new(message.strip)
      lines
      @result
    end

    private

    #########################################
    ###            branching              ###
    #########################################

    # arbitary line of a PO message. Can be comment or message
    # message parsing is always started with checking for msgctxt as content is expected in
    # msgctxt -> msgid -> msgid_plural -> msgstr order
    def lines
      if @scanner.scan(/#/)
        comment
      else
        message_context
      end
    end

    # match a comment line. called on lines starting with '#'.
    # Recalls line when the comment line was parsed
    def comment
      case @scanner.getch
      when ' '
        skip_whitespace
        add_result(:translator_comment, comment_text)
      when '.'
        skip_whitespace
        add_result(:extracted_comment, comment_text)
      when ':'
        skip_whitespace
        add_result(:reference, comment_text)
      when ','
        skip_whitespace
        add_result(:flag, comment_text)
      when '|'
        skip_whitespace
        previous_comments
      when '~'
        skip_whitespace
        add_result(:obsolete, comment_text)
      else
        @scanner.pos = @scanner.pos - 2
        raise PoParserError, "Unknown comment type '#{@scanner.peek(10)}'"
      end
      lines
    end

    def check_msg_start
      start = @scanner.scan(/msg/)
      raise PoParserError, "Invalid message start. Starts with #{@scanner.peek(10)}" unless start
      start
    end

    # matches the msgctxt line and will continue to check for msgid afterwards
    #
    # msgctxt is optional
    def msgctxt
      if @scanner.scan(/msgctxt/)
        skip_whitespace
        text = message_line
        add_result(:msgctxt, text)
        message_multiline(:msgctxt) if text.empty?
      end
      msgid
    end

    # matches the msgid line. Will check for optional msgid_plural.
    # Will advance to msgstr or msgstr_plural based on msgid_plural
    #
    # msgid is required
    def msgid
      if @scanner.scan(/msgid/)
        skip_whitespace
        text = message_line
        add_result(:msgid, text)
        message_multiline(:msgid) if text.empty?
        if msgid_plural
          msgstr_plural
        else
          msgstr
        end
      else
        raise PoParserError, "Message without msgid is not allowed. Line started unexpectedly with #{@scanner.peek(10)}."
      end
    end

    # matches the msgid_plural line.
    #
    # msgid_plural is optional
    #
    # @return [boolean] true if msgid_plural is present, false otherwise
    def msgid_plural
      if @scanner.scan(/msgid_plural/)
        skip_whitespace
        text = message_line
        add_result(:msgid_plural, text)
        message_multiline(:msgid) if text.empty?
        true
      else
        false
      end
    end

    # matches the msgstr singular line
    #
    # msgstr is required in singular translations
    def msgstr
      if @scanner.scan(/msgstr/)
        skip_whitespace
        text = message_line
        add_result(:msgstr, text)
        message_multiline(:msgstr) if text.empty?
      else
       raise PoParserError, "Singular message without msgstr is not allowed. Line started unexpectedly with #{@scanner.peek(10)}."
      end
    end


    def msgstr_plural(num = 0)
      msgstr_key = @scanner.scan(/msgstr\[\d\]/) # matches 'msgstr[0]' to 'msgstr[9]'
      if msgstr_key
        # msgstr plurals must come in 0-based index in order
        msgstr_num = msgstr_key.match(/\d/)[0].to_i
        raise PoParserError, "Bad 'msgstr[index]' index." if msgstr_num != num
        text = message_line
        add_result(msgstr_key, text)
        message_multiline(msgstr_key) if text.empty?
        msgstr_plural(num+1)
      elsif num == 0 # and msgstr_key was false
        raise PoParserError, "Plural message without msgstr[0] is not allowed. Line started unexpectedly with #{@scanner.peek(10)}."
      else
        raise PoParserError, "End of message was expected, but line started unexpectedly with #{@scanner.peek(10)}" unless @scanner.eos?
      end
    end

    def previous_comments
      # next part must be msgctxt, msgid or msgid_plural
      if @scanner.scan(/msg/)
        if @scanner.scan(/id/)
          if @scanner.scan(/_plural/)
            key = :previous_msgid_plural
          else
            key = :previous_msgid
          end
        elsif @scanner.scan(/ctxt/)
          key = :previous_msgctxt
        else
          raise PoParserError, "Previous comment type '#| msg#{@scanner.peek(10)}' unknown."
        end
        skip_whitespace
        text = message_line
        add_result(key, text)
        previous_multiline(key) if text.empty?
      else
        raise PoParserError, "Previous comments must start with '#| msg'. '#| #{@scanner.peek(10)}' unknown."
      end
    end

    def previous_multiline(key)
      # scan multilines until no further multiline is hit
      # /#|\p{Blank}"/ needs to catch the double quote to ensure it hits a previous
      # multiline and not another line type.
      if @scanner.scan(/#|\p{Blank}*"/)
        @scanner.pos = @scanner.pos - 1 # go one character back, so we can reuse the "message line" method
        add_result(key, message_line)
        previous_miltiline(key) # go on until we no longer hit a multiline line
      end
    end

    def message_multiline(key)
      skip_whitespace
      if @scanner.check(/"/)
        add_result(key, message_line)
        message_multiline(key)
      end
    end


    # identifies a message line and returns it's text or raises an error
    #
    # @return [String] message_text
    def message_line
      if @scanner.getch == '"'
        text = message_text
        raise PoParserError, "The message text '#{text}' must be finished with the double quote character '\"'." unless @scanner.getch == '"'
        skip_whitespace
        raise PoParserError, "There should be only whitespace until the end of line after the double quote character of a message text." unless end_of_line
        text
      else
        raise PoParserError, "A message text needs to start with the double quote character '\"'. This was supposed to be a message text but no double quote was found. #{@scanner.peek(20)}"
      end
    end


    #########################################
    ###             scanning              ###
    #########################################

    # returns the text of a comment
    #
    # @return [String] text
    def comment_text
      text = @scanner.scan(/.*/) # everything until newline
      text.rstrip! # benchmarked faster too rstrip the string in place even though adding 2 loc
      raise PoParserError, "Comment text should advance to next line or stop at eos" unless end_of_line
      text
    end

    # returns the text of a message line
    #
    # @return [String] text
    def message_text
      @scanner.scan_until(/(\\(\\|")|[^"])*/) # this parses anything until an unescaped quote is hit
    end

    # advances the scanner until the next non whitespace position.
    # Does not match newlines. See WHITESPACE_REGEX constant
    def skip_whitespace
      @scanner.skip(/\p{Blank}+/)
    end

    # returns true if the scanner is at beginning of next line or end of string
    def end_of_line
      @scanner.scan(/\n/)
      @scanner.eos? || @scanner.bol?
    end

    # adds text to the given key in results
    # creates an array if the given key already has a result
    def add_result(key, text)
      if @result[key]
        if @result[key].is_a? Array
          @result[key].push(text)
        else
          @result[key] = [@result[key], text]
        end
      else
        @result[key] = text
      end
    end

  end

end
