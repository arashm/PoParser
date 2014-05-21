module PoParser
  class Message
    attr_accessor :type, :str

    def initialize(type, str)
      @type = type
      @str  = str
    end

    def to_s(with_label = false)
      return @str unless with_label
      if @str.is_a? Array
        # multiline messages should be started with an empty line
        lines = ["#{ENTRIES_LABELS[@type]} \"\"\n"]
        @str.each do |str|
          lines << "\"#{str}\"\n"
        end
        return lines.join
      else
        "#{ENTRIES_LABELS[@type]} \"#{@str}\"\n"
      end
    end

    def to_str
      @str
    end
  end
end
