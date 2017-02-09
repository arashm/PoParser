module PoParser
  module FastParser
    require 'strscan'
    extend self

    # parse a single message of the PO format.
    #
    # @param message a single PO message in String format without leading or trailing whitespace
    # @return [Hash] parsed PO message information in Hash format
    def parse(message)
      @result = {}
      @scanner = StringScanner.new(message.strip)
      line

      @result
    end

    private

    #########################################
    ###            branching              ###
    #########################################

    # arbitary line of a PO message. Can be comment or message
    def lines
      case @scanner.getch
      when '#'
        comment
      when 'm'
        message
      else
        @scanner.pos = @scanner.pos - 1
        raise PoParserError "Invalid line start sequence. Line starts with #{@scanner.peek(10)}"
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
        raise PoParserError "Unknown comment type '#{@scanner.peek(10)}'"
      end

      line
    end

    # matche a message line. Will call it self recursevely until EOS or a parser error
    #
    def message
      if @scanner.scan(/msg/)
        if @scanner.scan(/id/)
          if @scanner.scan(/_plural/)
            type = :msgid_plural
          else
            type = :msgid
          end
        elsif @scanner.scan(/str/)
          type = :msgstr
          # TODO: handle plural messages

        elsif @scanner.scan(/ctxt/)
          type = :msgctxt
        else
          # TODO: error unknown message
        end
        skip_whitespace
        text = message_line
        add_result(type, text)
        message_multiline(type) if text.empty?
        message # call message recursive to get all following message lines but no longer comments
      elsif !@scanner.eos?
        raise PoParserError "Message lines need to start with an 'm'. Line starts with #{@scanner.peek(10)}"
      end
    end

    def previous_comments
      # next part must be msgctxt, msgid or msgid_plural
      if @scanner.scan(/msg/)
        if @scanner.scan(/id/)
          if @scanner.scan(/_plural/)
            type = :previous_msgid_plural
          else
            type = :previous_msgid
          end
        elsif @scanner.scan(/ctxt/)
          type = :previous_msgctxt
        else
          raise PoParserError "Previous comment type '#| msg#{@scanner.peek(10)}' unknown."
        end
        skip_whitespace
        text = message_line
        add_result(type, text)
        previous_multiline(type) if text.empty?
      else
        raise PoParserError "Previous comments must start with '#| msg'. '#| #{@scanner.peek(10)}' unknown."
      end
    end

    def previous_multiline(type)
      # scan multilines until no further multiline is hit
      # /#|\p{Blank}"/ needs to catch the double quote to ensure it hits a previous
      # multiline and not another line type.
      if @scanner.scan(/#|\p{Blank}*"/)
        @scanner.pos = @scanner.pos - 1 # go one character back, so we can reuse the "message line" method
        add_result(type, message_line)
        previous_miltiline(type) # go on until we no longer hit a multiline line
      end
    end

    def message_multiline(type)
      skip_whitespace
      if @scanner.check(/"/)
        add_result(type, message_line)
        message_multiline(type)
      end
    end


    # identifies a message line and returns it's text or raises an error
    #
    # @return [String] message_text
    def message_line
      if @scanner.getch == '"'
        text = message_text
        raise PoParserError "The message text '#{text}' must be finished with the double quote character '\"'." unless @scanner.getch == '"'
        skip_whitespace
        raise PoParserError "There should be only whitespace until the end of line after the double quote character of a message text." unless end_of_line
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
      text = @scanner.scan(/.*/) # everything until newline
      text.rstrip! # benchmarked faster too rstrip the string in place even though adding 2 loc
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
