module PoParser
  class Comment
    attr_accessor :type, :value

    def initialize(type, value)
      @type = type
      @value  = value
    end

    def to_s(with_label = false)
      return to_str unless with_label
      if @value.is_a? Array
        string = []
        @value.each do |str|
          string << "#{COMMENTS_LABELS[@type]} #{str}\n".gsub(/[^\S\n]+$/, '')
        end
        return string.join
      else
        # removes the space but not newline at the end
        "#{COMMENTS_LABELS[@type]} #{@value}\n".gsub(/[^\S\n]+$/, '')
      end
    end

    def to_str
      @value.is_a?(Array) ? @value.join : @value
    end

    def inspect
      @value
    end
  end
end
