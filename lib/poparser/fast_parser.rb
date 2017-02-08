module PoParser
  module FastParser
    require 'strscan'
    extend self

    # precompile regex as constants for speed
    WHITESPACE_REGEX = /\p{Blank}+/
    TEXT = /(\\(\\|")|[^"])*/ # this parses anything until an unescaped quote is hit

    # parse a single message of the PO format
    #
    # @param message a single PO message in String format without leading or trailing whitespace
    # @return [Hash] parsed PO message information in Hash format
    def parse(message)
      @result = {}
      @scanner = StringScanner.new(message)
      start

      @result
    end

    private

    #########################################
    ###            branching              ###
    #########################################

    # start of a PO message. Can be comment or message
    def start
      case @scanner.getch
      when '#'
        comment
      when 'm'
        message
      else
        raise PoParserError "Invalid line start sequence"
      end
    end

    # matches message lines
    #
    # this is used after first message, so further only messages are allowed
    def messages
      case @scanner.getch
      when 'm'
        message
      else
        raise PoParserError "Message lines need to start with an 'm'"
      end
    end

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
        raise PoParserError "Unknown comment type"
      end
    end

    def previous_comments
      # next part must be msgctxt, msgid or msgid_plural
      if @scanner.scan(/^msg/)
        if @scanner.scan(/^ctxt/)
          skip_whitespace
          add_result(:previous_msgctxt, message_text)
          previous_multiline
        else

        end
      else
        raise PoParserError "Previous comments must start with #| msg"
      end
    end

    def previous_multiline

    end

    # identifies a message line and returns it's text or raises an error
    #
    # @return [String] message_text
    def message_line
      if @scanner.getch == '"'
        text = message_text
        raise PoParserError "a message text must be finished with the double quote character '\"'" unless @scanner.getch == '"'
        skip_whitespace
        raise PoParserError "there should be only whitespace until the end of line after the double quote character of a message text"
        text
      else
        raise PoParserError "A message text needs to start with the double quote character '\"'. This was supposed to be a message text but no double quote was found."
      end
    end


    #########################################
    ###             scanning              ###
    #########################################

    # returns the text of a comment
    #
    # @return [String] text
    def comment_text
      @scanner.scan(/.*/) # everything until newline
    end

    # returns the text of a message line
    #
    # @return [String] text
    def message_text
      @scanner.scan_until(TEXT)
    end

    # advances the scanner until the next non whitespace position.
    # Does not match newlines. See WHITESPACE_REGEX constant
    def skip_whitespace
      @scanner.skip(WHITESPACE_REGEX)
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
