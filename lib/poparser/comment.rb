module PoParser
  class Comment
    attr_accessor :type, :value

    def initialize(type, value)
      @type = type
      @value  = value

      if @type.to_s =~ /^previous_/ # these behave more like messages
        remove_empty_line
      end
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
      if @value.is_a?(Array)
        if @type.to_s =~ /^previous_/ # these behave more like messages
          @value.join
        else
          @value.join("\n")
        end
      else
        @value
      end
    end

    def inspect
      @value
    end

  private
    def remove_empty_line
      if @value.is_a? Array
        @value.shift if @value.first == ''
      end
    end
  end
end
