# frozen_string_literal: true

module PoParser
  class Message
    attr_accessor :type

    def initialize(type, value)
      @type = type
      @value = value.is_a?(Array) ? value : value.split("\\n")

      remove_empty_line
    end

    def value=(val)
      @value = val.is_a?(Array) ? val : val.split("\\n")
    end

    def value
      return @value if plural?

      @value.join
    end
    alias to_str value

    def str
      @value.join
    end
    alias inspect str

    def to_s(with_label = false)
      return to_str unless with_label

      if plural?
        remove_empty_line
        lines = []
        # multiline messages should be started with an empty line
        lines.push("#{label} \"\"\n")
        @value.each do |str|
          lines << "\"#{str}\"\n"
        end
        return lines.join
      end

      "#{label} \"#{@value.join}\"\n"
    end

  private

    def remove_empty_line
      return unless plural? && @value.first.empty?

      @value.shift
    end

    def label
      if /msgstr\[[0-9]\]/.match?(@type.to_s)
        @type
      else
        ENTRIES_LABELS[@type]
      end
    end

    def plural?
      @value.size > 1
    end
  end
end
