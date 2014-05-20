module PoParser
  class Entry
    # LABELS.each do |label|
    #   attr_reader label
    # end

    # TODO: raise error if a label is not known
    def initialize(args= {})
      LABELS.each do |label|
        instance_variable_set "@#{label.to_s}".to_sym, nil
      end

      args.each do |type, string|
        if COMMENTS_LABELS.include? type
          instance_variable_set "@#{label.to_s}".to_sym, Comment.new(type, string)
        elsif ENTRIES_LABELS.include? type
          instance_variable_set "@#{label.to_s}".to_sym, Message.new(type, string)
        end
      end

      define_writer_methods
      define_reader_methods
    end

    def define_writer_methods
      COMMENTS_LABELS.each do |type, mark|
        self.class.send(:define_method, "#{type}=".to_sym) do |val|
          lambda do
            instance_variable_set "@#{type}".to_sym, Comment.new(type, val)
          end
        end
      end

      ENTRIES_LABELS.each do |type, mark|
        self.class.send(:define_method, "#{type}=".to_sym) do |val|
          instance_variable_set "@#{type}".to_sym, Message.new(type, val)
        end
      end

      self.class.send(:alias_method, :translate, :msgstr=)
    end

    def define_reader_methods
      LABELS.each do |label|
        self.class.send(:define_method, label.to_sym) do
          object = instance_variable_get "@#{label}".to_sym
          object
        end
      end
    end


    # Checks if the entry is untraslated
    # 
    # @return [Boolean]
    def untranslated?
      @msgstr.nil? || @msgstr == ''
    end
    alias_method :incomplete? , :untranslated?

    # Checks if the entry is translated
    # 
    # @return [Boolean]
    def translated?
      not untranslated?
    end
    alias_method :complete? , :translated?

    # Checks if the entry is plural
    # 
    # @return [Boolean]
    def plural?
      @msgid_plural != nil
    end

    # Checks if the entry is fuzzy
    # 
    # @return [Boolean]
    def fuzzy?
      binding.pry
      @flag == 'fuzzy'
    end

    # Flag the entry as Fuzzy
    def flag_as_fuzzy
      @flag = 'fuzzy'
    end

    # Set flag to a custome string
    def flag_as(flag)
      raise ArgumentError if flag.class != String
      @flag = flag
    end

    # Convert entry to a hash key value
    def to_h
      hash = {}
      LABELS.each do |label|
        # binding.pry if label == :msgid
        hash[label] = send(label).to_s if not send(label) == '' || send(label).nil?
      end
      hash
    end

    def to_s
      lines = []
      comment_labels = COMMENTS_LABELS.keys
      LABELS.each do |label|
        lines << send(label).to_s if !send(label).nil?
      end

      lines.join("\n")
    end
  end
end
