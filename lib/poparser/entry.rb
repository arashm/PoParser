module PoParser
  class Entry
    # TODO: raise error if a label is not known
    def initialize(args = {})
      # Defining all instance variables to prevent warnings
      LABELS.each do |label|
        instance_variable_set "@#{label.to_s}".to_sym, nil
      end

      # Set passed arguments
      args.each do |name, value|
        raise(ArgumentError, "Unknown label #{name}") if !valid_label? name
        set_instance_variable(name, value)
      end

      define_writer_methods(COMMENTS_LABELS, 'Comment')
      define_writer_methods(ENTRIES_LABELS, 'Message')
      define_reader_methods

      self.class.send(:alias_method, :translate, :msgstr=)
      self.class.send(:alias_method, :cached, :obsolete)
      self.class.send(:alias_method, :cached=, :obsolete=)
      # alias for backward compatibility of this typo
      self.class.send(:alias_method, :refrence, :reference)
      self.class.send(:alias_method, :refrence=, :reference=)
      if self.obsolete?
        obsolete_content = SimplePoParser.parse_message(obsolete.value.join("\n").gsub(/^\|/, "#|"))
        obsolete_content.each do |name, value|
          raise(ArgumentError, "Unknown label #{name}") if !valid_label? name
          set_instance_variable(name, value)
        end
      end
    end

    # If entry doesn't have any msgid, it's probably a obsolete entry that is
    # kept by the program for later use. These entries will usually start with: #~
    #
    # @return [Boolean]
    def obsolete?
      !@obsolete.nil?
    end
    alias_method :cached?, :obsolete?

    # Checks if the entry is untraslated
    #
    # @return [Boolean]
    def untranslated?
      return false if obsolete? || fuzzy?
      if @msgstr.is_a? Array
        return @msgstr.map {|ms| ms.str}.join.empty?
      end
      @msgstr.nil? || @msgstr.str.empty?
    end
    alias_method :incomplete? , :untranslated?

    # Checks if the entry is translated
    #
    # @return [Boolean]
    def translated?
      return false if obsolete? || fuzzy?
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
      return false if obsolete?
      @flag.to_s.match('fuzzy') ? true : false
    end

    # Flag the entry as Fuzzy
    # @return [Entry]
    def flag_as_fuzzy
      @flag = 'fuzzy'
      self
    end

    # Set flag to a custom string
    def flag_as(flag)
      raise ArgumentError if flag.class != String
      @flag = flag
    end

    # Convert entry to a hash key value
    # @return [Hash]
    def to_h
      hash = {}
      instance_variables.each do |label|
        object = instance_variable_get(label)
        # If it's a plural msgstr
        if object.is_a? Array
          object.each do |entry|
            hash[entry.type] = entry.to_s if not entry.nil?
          end
        else
          hash[object.type] = object.to_s if not object.nil?
        end
      end
      hash
    end

    # Convert entry to a string
    # @return [String]
    def to_s
      lines = []
      LABELS.each do |label|
        object = instance_variable_get("@#{label}".to_sym)
        # If it's a plural msgstr
        if object.is_a? Array
          object.each do |entry|
            lines << entry.to_s(true) if not entry.nil?
          end
        else
          lines << object.to_s(true) if not object.nil?
        end
      end

      lines.join
    end

    def inspect
      to_s
    end

    private

    def set_instance_variable(name, value)
      if COMMENTS_LABELS.include? name
        instance_variable_set "@#{name.to_s}".to_sym, Comment.new(name, value)
      elsif ENTRIES_LABELS.include? name
        instance_variable_set "@#{name.to_s}".to_sym, Message.new(name, value)
      elsif name.to_s.match(/^msgstr\[[0-9]\]/)
        # If it's a plural msgstr
        @msgstr ||= []
        @msgstr << Message.new(name, value)
      end
    end

    def define_writer_methods(labels, object)
      object = PoParser.const_get(object)
      labels.each do |type, mark|
        unless Entry.method_defined? "#{type}=".to_sym
          self.class.send(:define_method, "#{type}=".to_sym, lambda { |val|
            if instance_variable_get("@#{type}".to_sym).is_a? object
              klass      = instance_variable_get "@#{type}".to_sym
              klass.type = type
              klass.value  = val
            else
              instance_variable_set "@#{type}".to_sym, object.new(type, val)
            end
            # return value
            instance_variable_get "@#{type}".to_sym
          })
        end
      end
    end

    def define_reader_methods
      LABELS.each do |label|
        unless Entry.method_defined? "#{label}".to_sym
          self.class.send(:define_method, label.to_sym) do
            instance_variable_get "@#{label}".to_sym
          end
        end
      end
    end

    def valid_label?(label)
      !(label =~ /^msgstr\[[0-9]\]/).nil? || LABELS.include?(label)
    end
  end
end
