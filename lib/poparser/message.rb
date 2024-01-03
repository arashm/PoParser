# frozen_string_literal: true

module PoParser
  class Message
    attr_accessor :type, :value

    def initialize(type, value)
      @type = type
      @value = value

      remove_empty_line
    end

    def str
      @value.is_a?(Array) ? @value.join : @value
    end

    def to_s(with_label = false)
      return to_str unless with_label

      if @value.is_a? Array
        remove_empty_line
        # multiline messages should be started with an empty line
        lines = ["#{label} \"\"\n"]
        @value.each do |str|
          lines << "\"#{str}\"\n"
        end
        lines.join
      else
        "#{label} \"#{@value}\"\n"
      end
    end

    def to_str
      @value.is_a?(Array) ? @value.join : @value
    end

    def inspect
      @value
    end

  private

    def remove_empty_line
      return unless @value.is_a?(Array)

      @value.shift if @value.first == ''
    end

    def label
      if /msgstr\[[0-9]\]/.match?(@type.to_s)
        @type
      else
        ENTRIES_LABELS[@type]
      end
    end
  end
end
