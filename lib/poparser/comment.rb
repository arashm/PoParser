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
        if @type.to_s =~ /^previous_/ # these behave more like messages
          string = ["#{COMMENTS_LABELS[@type]} \"\"\n"]
          @value.each do |str|
            string << "#| \"#{str}\"\n".gsub(/[\p{Blank}]+$/, '')
          end
        else
          string = []
          @value.each do |str|
            string << "#{COMMENTS_LABELS[@type]} #{str}\n".gsub(/[\p{Blank}]+$/, '')
          end
        end
        return string.join
      else
        if @type.to_s =~ /^previous_/ # these behave more like messages
          "#{COMMENTS_LABELS[@type]} \"#{@value}\"\n".gsub(/[\p{Blank}]+$/, '')
        else
          # removes the space but not newline at the end
          "#{COMMENTS_LABELS[@type]} #{@value}\n".gsub(/[\p{Blank}]+$/, '')
        end
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
