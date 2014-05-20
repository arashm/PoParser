module PoParser
  class Message
    def initialize(type, str)
      @type = type
      @str  = str
    end

    def to_s(with_label = false)
      return @str unless with_labels
      if @str.is_a? Array
        # multiline messages should be started with an empty line
        lines = ["#{ENTRIES_LABELS[@type]} \"\""]
        @str.each do |str|
          lines << "\"#{str}\""
        end
        return lines.join("\n")
      else
        "#{ENTRIES_LABELS[@type]} \"#{@str}\"\n"
      end
    end

    def to_str
      @str
    end
  end
end
