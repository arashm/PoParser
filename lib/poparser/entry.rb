# frozen_string_literal: true

module PoParser
  # A single translation entity in a PO file
  class Entry # rubocop:disable Metrics/ClassLength
    def initialize(args = {})
      # Defining all instance variables to prevent warnings
      define_labels_instance_variables
      define_args_instance_variables(args)
      define_writer_methods(COMMENTS_LABELS, 'Comment')
      define_writer_methods(ENTRIES_LABELS, 'Message')
      define_reader_methods
      define_aliases
      define_obsolete_instance_variables
    end

    # If entry doesn't have any msgid, it's probably a obsolete entry that is
    # kept by the program for later use. These entries will usually start
    # with: #~
    #
    # @return [Boolean]
    def obsolete?
      !@obsolete.nil?
    end
    alias cached? obsolete?

    # Checks if the entry is untraslated
    #
    # @return [Boolean]
    def untranslated?
      return false if obsolete? || fuzzy?
      return @msgstr.map(&:str).join.empty? if @msgstr.is_a? Array

      @msgstr.nil? || @msgstr.str.empty?
    end
    alias incomplete? untranslated?

    # Checks if the entry is translated
    #
    # @return [Boolean]
    def translated?
      return false if obsolete? || fuzzy?

      !untranslated?
    end
    alias complete? translated?

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

      @flag.to_s.match?('fuzzy') ? true : false
    end

    # Flag the entry as Fuzzy
    #
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
    #
    # @return [Hash]
    def to_h
      instance_variables.each_with_object({}) do |label, hash|
        object = instance_variable_get(label)
        next if object.nil?

        # If it's a multiline message/comment
        if object.value.is_a?(Array)
          hash[object.type] = object.value.compact
        else
          hash[object.type] = object.to_s
        end
      end
    end

    # Convert entry to a string
    #
    # @return [String]
    def to_s
      LABELS.each_with_object([]) do |label, arr|
        object = instance_variable_get("@#{label}".to_sym)
        # If it's a plural msgstr
        if object.is_a?(Array)
          arr.push(*object.map { |entry| entry.to_s(true) }.compact)
        else
          arr << object.to_s(true) unless object.nil?
        end
      end.join
    end

    def inspect
      to_s
    end

  private

    def set_instance_variable(name, value)
      if COMMENTS_LABELS.include? name
        instance_variable_set "@#{name}".to_sym, Comment.new(name, value)
      elsif ENTRIES_LABELS.include? name
        instance_variable_set "@#{name}".to_sym, Message.new(name, value)
      elsif /^msgstr\[[0-9]\]/.match?(name.to_s)
        # If it's a plural msgstr, change instance variable name to @msgstr_n as @msgstr[n] is not a valid variable name
        instance_variable_set "@msgstr_#{plural_form(name)}".to_sym, Message.new(name, value)
      end
    end

    def define_writer_methods(labels, object)
      object = PoParser.const_get(object)

      labels.each do |type, _mark|
        next if Entry.method_defined?("#{type}=".to_sym)

        define_writer_method(type, object)
      end
    end

    def define_writer_method(type, object)
      self.class.send(:define_method, "#{type}=".to_sym, lambda { |val|
        if instance_variable_get("@#{type}".to_sym).is_a? object
          klass       = instance_variable_get "@#{type}".to_sym
          klass.type  = type
          klass.value = val
        elsif type.match(/^msgstr_\d/)
          plural_form = type.to_s.scan(/^msgstr_(\d)/).last.first.to_i
          object_type = "msgstr[#{plural_form}]".to_sym
          instance_variable_set "@#{type}".to_sym, object.new(object_type, val)
        else
          instance_variable_set "@#{type}".to_sym, object.new(type, val)
        end
        # return value
        instance_variable_get "@#{type}".to_sym
      })
    end

    def define_reader_methods
      LABELS.each do |label|
        next if Entry.method_defined? label.to_s.to_sym

        self.class.send(:define_method, label.to_sym) do
          instance_variable_get "@#{label}".to_sym
        end
      end
    end

    def valid_label?(label)
      !(label =~ /^msgstr\[[0-9]\]/).nil? || LABELS.include?(label)
    end

    def define_labels_instance_variables
      LABELS.each { |label| instance_variable_set("@#{label}".to_sym, nil) }
    end

    def define_obsolete_instance_variables
      return unless obsolete?

      obsolete_content = SimplePoParser.parse_message(
        obsolete.value.join("\n").gsub(/^\|/, '#|'),
      )

      obsolete_content.each do |name, value|
        raise(ArgumentError, "Unknown label #{name}") unless valid_label? name

        set_instance_variable(name, value)
      end
    end

    def define_args_instance_variables(args)
      # Set passed arguments
      args.each do |name, value|
        raise(ArgumentError, "Unknown label #{name}") unless valid_label? name

        set_instance_variable(name, value)
      end
    end

    def define_aliases
      self.class.send(:alias_method, :translate, :msgstr=)
      self.class.send(:alias_method, :cached, :obsolete)
      self.class.send(:alias_method, :cached=, :obsolete=)
      # alias for backward compatibility of this typo
      self.class.send(:alias_method, :refrence, :reference)
      self.class.send(:alias_method, :refrence=, :reference=)
    end

    def plural_form(name)
      name.to_s.scan(/^msgstr\[([0-9])\]/).last.first.to_i
    end
  end
end
