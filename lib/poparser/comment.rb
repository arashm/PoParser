module PoParser
  class Comment
    attr_accessor :type, :str

    def initialize(type, str)
      @type = type
      @str  = str
    end

    def to_s(with_label = false)
      return @str unless with_label
      if @str.is_a? Array
        string = []
        @str.each do |str|
          string << "#{COMMENTS_LABELS[@type]} #{str}\n"
        end
        return string.join
      else
        "#{COMMENTS_LABELS[@type]} #{@str}\n"
      end
    end

    def to_str
      @str
    end
  end
end
