module PoParser
  class Entry
    # TODO: raise error if a label is not known
    def initialize(args= {})
      # Defining all instance variables to prevent warnings
      LABELS.each do |label|
        instance_variable_set "@#{label.to_s}".to_sym, nil
      end

      # Set passed arguments
      args.each do |type, string|
        if COMMENTS_LABELS.include? type
          instance_variable_set "@#{type.to_s}".to_sym, Comment.new(type, string)
        elsif ENTRIES_LABELS.include? type
          instance_variable_set "@#{type.to_s}".to_sym, Message.new(type, string)
        elsif type.to_s.match(/^msgstr\[[0-9]\]/)
          # If it's a plural msgstr
          @msgstr ||= []
          @msgstr << Message.new(type, string)
        end
      end

      define_writer_methods
      define_reader_methods
    end

    # Checks if the entry is untraslated
    # 
    # @return [Boolean]
    def untranslated?
      @msgstr.nil? || @msgstr.to_s == ''
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
      @flag.to_s == 'fuzzy'
    end

    # Flag the entry as Fuzzy
    # @return [Entry]
    def flag_as_fuzzy
      @flag = 'fuzzy'
      self
    end

    # Set flag to a custome string
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
  
  private

    def define_writer_methods
      COMMENTS_LABELS.each do |type, mark|
        unless Entry.method_defined? "#{type}=".to_sym
          self.class.send(:define_method, "#{type}=".to_sym, lambda { |val|
            if instance_variable_get("@#{type}".to_sym).is_a? Comment
              comment = instance_variable_get "@#{type}".to_sym
              comment.type = type
              comment.str = val
            else
              instance_variable_set "@#{type}".to_sym, Comment.new(type, val)
            end
            instance_variable_get "@#{type}".to_sym
          })
        end
      end

      ENTRIES_LABELS.each do |type, mark|
        unless Entry.method_defined? "#{type}=".to_sym
          self.class.send(:define_method, "#{type}=".to_sym, lambda { |val|
            if instance_variable_get("@#{type}".to_sym).is_a? Message
              message = instance_variable_get "@#{type}".to_sym
              message.type = type
              message.str = val
            else
              instance_variable_set "@#{type}".to_sym, Message.new(type, val)
            end
            instance_variable_get "@#{type}".to_sym
          })
        end
      end

      self.class.send(:alias_method, :translate, :msgstr=)
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

  end
end
