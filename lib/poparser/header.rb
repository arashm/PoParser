module PoParser
  class Header
    attr_reader :entry, :original_configs
    attr_accessor :comments, :pot_creation_date, :po_revision_date, :project_id,
            :report_to, :last_translator, :team, :language, :charset,
            :encoding, :plural_forms

    def initialize(entry)
      @entry            = entry
      @comments         = entry.translator_comment.to_s
      @original_configs = convert_msgstr_to_hash(entry.msgstr)

      HEADER_LABELS.each do |k, v|
        instance_variable_set "@#{k.to_s}".to_sym, @original_configs[v]
      end
    end

    def configs
      hash = {}
      HEADER_LABELS.each do |k, v|
        hash[v] = instance_variable_get "@#{k}".to_sym
      end
      @original_configs.merge(hash)
    end

    def to_h
      @entry.to_h
    end

    def to_s
      string = []
      @comments.each do |comment|
        string << "# #{comment}".strip
      end
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
        if key.length == 1
          array[index -1][1] += key[0]
          array.delete_at(index)
        end
      end
    end
  end
end
