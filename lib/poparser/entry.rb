module PoParser
  class Entry
    LABELS.each do |label|
      attr_accessor label
    end

    def initialize(args= {})
      LABELS.each do |label|
        instance_variable_set("@#{label.to_s}", args.fetch(label, nil))
      end
    end
    
    alias_method :translate, :msgstr=

    def translated?
      @msgstr != nil
    end
    alias_method :complete? , :translated?

    def plural?
      @msgid_plural != nil
    end

    def fuzzy?
      @flag == 'fuzzy'
    end

    def flag_as_fuzzy
      @flag = 'fuzzy'
    end

    def flag_as(flag)
      raise ArgumentError if flag.class != String
      @flag = flag
    end

    def to_h
      hash = {}
      LABELS.each do |label|
        hash[label] = send(label) if send(label) != nil
      end
      hash
    end
  end
end
