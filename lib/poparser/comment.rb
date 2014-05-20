module PoParser
  class Comment
    def initialize(type, str)
      @type = type
      @str  = str
    end

    def to_s(with_label = false)
      return @str unless with_label
      if @str.is_a? Array
        string = []
        @str.each do |str|
          string << "#{COMMENTS_LABELS[@type]} #{str}"
        end
        return string.join("\n")
      else
        "#{COMMENTS_LABELS[@type]} #{@str}\n"
      end
    end

    def to_str
      @str
    end
  end
end
