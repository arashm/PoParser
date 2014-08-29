module PoParser
  class Message
    attr_accessor :type
    attr_writer :str

    def initialize(type, str)
      @type = type
      @str  = str

      remove_empty_line
    end

    def str
      @str.is_a?(Array) ? @str.join : @str
    end

    def to_s(with_label = false)
      return @str unless with_label
      if @str.is_a? Array
        remove_empty_line
        # multiline messages should be started with an empty line
        lines = ["#{label} \"\"\n"]
        @str.each do |str|
          lines << "\"#{str}\"\n"
        end
        return lines.join
      else
        "#{label} \"#{@str}\"\n"
      end
    end

    def to_str
      @str.is_a?(Array) ? @str.join : @str
    end

    def inspect
      @str
    end

  private
    def remove_empty_line
      if @str.is_a? Array
        @str.shift if @str.first == ''
      end
    end

    def label
      if @type.to_s.match(/msgstr\[[0-9]\]/)
        @type
      else
        ENTRIES_LABELS[@type]
      end
    end
  end
end
