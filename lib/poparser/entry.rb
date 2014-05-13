module PoParser
  class Entry
    LABELS.each do |label|
      attr_accessor label
    end

    # TODO: raise error if a label is not known
    def initialize(args= {})
      LABELS.each do |label|
        instance_variable_set("@#{label.to_s}", args.fetch(label, nil))
      end
    end
    
    alias_method :translate, :msgstr=

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
        hash[label] = send(label) if send(label) != nil
      end
      hash
    end
  end
end
