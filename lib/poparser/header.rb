# frozen_string_literal: true

module PoParser
  # The very first entry of the PO file is considered the header
  class Header
    attr_reader :entry, :original_configs, :flag
    attr_accessor :comments, :pot_creation_date, :po_revision_date, :project_id,
                  :report_to, :last_translator, :team, :language, :charset,
                  :encoding, :plural_forms

    def initialize(entry)
      @entry            = entry
      @comments         = entry.translator_comment.value unless entry.translator_comment.nil?
      @original_configs = convert_msgstr_to_hash(entry.msgstr)
      @flag             = entry.flag

      define_labels_instance_variables
    end

    def configs
      configs = HEADER_LABELS.each_with_object({}) do |(k, v), hash|
        hash[v] = instance_variable_get "@#{k}".to_sym
      end
      @original_configs.merge(configs)
    end

    # Checks if the entry is fuzzy
    #
    # @return [Boolean]
    def fuzzy?
      @flag.to_s.match?('fuzzy') ? true : false
    end

    # Flag the entry as Fuzzy
    #
    # @return [Header]
    def flag_as_fuzzy
      @flag = 'fuzzy'
      self
    end

    # Set flag to a custom string
    def flag_as(flag)
      raise ArgumentError if flag.class != String

      @flag = flag
    end

    def to_h
      @entry.to_h
    end

    def to_s
      string = []
      if @comments.is_a?(Array)
        @comments.each do |comment|
          string << "# #{comment}".strip
        end
      else
        string << "# #{@comments}".strip
      end
      string << "#, #{@flag}" if @flag
      string << "msgid \"\"\nmsgstr \"\""
      configs.each do |k, v|
        if v.nil? || v.empty?
          puts "WARNING: \"#{k}\" header field is empty and skipped"
          next
        end

        string << "#{k}: #{v}\n".dump
      end
      string.join("\n")
    end

    def inspect
      string = []
      if @comments.is_a?(Array)
        @comments.each do |comment|
          string << "# #{comment}".strip
        end
      else
        string << "# #{@comments}".strip
      end
      string << "#, #{@flag}" if @flag
      string << "msgid \"\"\nmsgstr \"\""
      configs.each do |k, v|
        next if v.nil? || v.empty?

        string << "#{k}: #{v}\n".dump
      end
      string.join("\n")
    end

  private

    def convert_msgstr_to_hash(msgstr)
      options_array = msgstr.value.map do |options|
        options.split(':', 2).each do |k|
          k.strip!
          k.chomp!
          k.gsub!(/\\+n$/, '')
        end
      end
      Hash[merge_to_previous_string(options_array)]
    end

    # Sometimes long lines are wrapped into new lines, this function
    # join them back
    #
    # [['a', 'b'], ['c']] #=> [['a', 'bc']]
    def merge_to_previous_string(array)
      array.each_with_index do |key, index|
        next unless key.length == 1

        array[index - 1][1] += key[0]
        array.delete_at(index)
      end
    end

    def define_labels_instance_variables
      HEADER_LABELS.each do |k, v|
        instance_variable_set("@#{k}".to_sym, @original_configs[v])
      end
    end
  end
end
