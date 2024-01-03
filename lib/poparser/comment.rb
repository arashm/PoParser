# frozen_string_literal: true

module PoParser
  class Comment
    attr_accessor :type, :value

    def initialize(type, value)
      @type = type
      @value = value

      # these behave more like messages
      remove_empty_line if /^previous_/.match?(@type.to_s)
    end

    def to_s(with_label = false)
      return to_str unless with_label

      if @value.is_a? Array
        if /^previous_/.match?(@type.to_s) # these behave more like messages
          string = ["#{COMMENTS_LABELS[@type]} \"\"\n"]
          @value.each do |str|
            string << "#| \"#{str}\"\n".gsub(/\p{Blank}+$/, '')
          end
        else
          string = []
          @value.each do |str|
            string << "#{COMMENTS_LABELS[@type]} #{str}\n".gsub(/\p{Blank}+$/, '')
          end
        end
        string.join
      elsif /^previous_/.match?(@type.to_s)
        "#{COMMENTS_LABELS[@type]} \"#{@value}\"\n".gsub(/\p{Blank}+$/, '') # these behave more like messages
      else
        # removes the space but not newline at the end
        "#{COMMENTS_LABELS[@type]} #{@value}\n".gsub(/\p{Blank}+$/, '')
      end
    end

    def to_str
      if @value.is_a?(Array)
        if /^previous_/.match?(@type.to_s) # these behave more like messages
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
      @value.shift if @value.is_a?(Array) && @value.first == ''
    end
  end
end
