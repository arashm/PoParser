# frozen_string_literal: true

module PoParser
  # Po class keeps all entries of a Po file
  class Po
    include Enumerable
    attr_reader :header
    attr_accessor :path

    def initialize(args = {})
      @entries = []
      @path    = args.fetch(:path, nil)
    end

    # add new entries to po file
    #
    # @example
    #   entry = {
    #             translator_comment: 'comment',
    #             reference: 'reference comment',
    #             flag: 'fuzzy',
    #             msgid: 'translatable string',
    #             msgstr: 'translation'
    #           }
    #   add(entry)
    #
    # @param entry [Hash, Array] a hash of entry contents or an array of hashes
    # @return [Po]
    def add(entry)
      return import_hash(entry) if entry.is_a?(Hash)
      return import_array(entry) if entry.is_a?(Array)

      raise ArgumentError, 'Must be a hash or an array of hashes'
    end
    alias << add

    # Delete entry from po file
    #
    # @example
    #
    #   delete(entry)
    #
    # @param entry [Entry] to be deleted
    # @return [Entry]
    def delete(entry)
      raise(ArgumentError, 'Must be an Entry') unless entry.is_a?(PoParser::Entry)

      @entries.delete(entry)
    end

    # Returns an array of all entries in po file
    #
    # @param include_obsolete [Boolean] Whether include obsolete entries or not
    # @return [Array]
    def entries(include_obsolete = false)
      return @entries if include_obsolete

      find_all { |entry| !entry.obsolete? }
    end
    alias all entries

    # Finds all entries that are flaged as fuzzy
    #
    # @return [Array] an array of fuzzy entries
    def fuzzy
      find_all(&:fuzzy?)
    end

    # Finds all entries that are untranslated
    #
    # @return [Array] an array of untranslated entries
    def untranslated
      find_all(&:untranslated?)
    end

    # Finds all entries that are translated
    #
    # @return [Array] an array of translated entries
    def translated
      find_all(&:translated?)
    end

    # Finds all obsolete entries
    #
    # @return [Array] an array of obsolete entries
    def obsolete
      find_all(&:obsolete?)
    end
    alias cached obsolete

    # Count of all entries without counting obsolete entries
    #
    # @return [String]
    def size
      entries.length
    end
    alias length size

    # Search for entries with provided string
    #
    # @param label [Symbol] One of the known LABELS
    # @param string [String] String to search for
    # @return [Array] Array of matched entries
    def search_in(label, string)
      raise(ArgumentError, "Unknown key: #{label}") unless LABELS.include?(label.to_sym)

      find_all do |entry|
        text = entry.send(label).str
        text.match(/#{string}/i)
      end
    end

    # Shows statistics and status of the provided file in percentage.
    #
    # @return [Hash] a hash of translated, untranslated and fuzzy percentages
    def stats
      untranslated_size = untranslated.size
      translated_size   = translated.size
      fuzzy_size        = fuzzy.size

      {
        translated: percentage(translated_size),
        untranslated: percentage(untranslated_size),
        fuzzy: percentage(fuzzy_size),
      }
    end

    # Converts Po file to an hashes of entries
    #
    # @return [Array] array of hashes of entries
    def to_h
      array = @entries.map(&:to_h)
      array.unshift(@header.to_h) if @header
      array
    end

    # Shows a String representation of the Po file
    #
    # @return [String]
    def to_s
      array = @entries.map(&:to_s)
      # add a blank line after header
      array.unshift(@header.to_s, '') if @header
      array.join("\n")
    end

    # Saves the file to the provided path
    def save_file
      raise ArgumentError, 'Need a Path to save the file' if @path.nil?

      File.open(@path, 'w') { |file| file.write(to_s) }
    end

    def each
      @entries.each do |entry|
        yield entry
      end
    end

    def inspect
      "<#{self.class.name}, Translated: #{translated.length}"\
        "(#{stats[:translated]}%) Untranslated: #{untranslated.length}"\
        "(#{stats[:untranslated]}%) Fuzzy: #{fuzzy.length}(#{stats[:fuzzy]}%)>"
    end

  private

    # calculates percentages based on total number of entries
    #
    # @param [Integer] number of entries
    # @return [Float] percentage of the provided entries
    def percentage(count)
      ((count.to_f / size) * 100).round(1)
    end

    def import_hash(entry)
      add_entry(entry)

      self
    end

    def import_array(entry)
      entry.each { |en| add_entry(en) }

      self
    end

    # rubocop:disable Style/SafeNavigation
    def add_entry(entry)
      return add_header_entry(entry) if entry[:msgid] && entry[:msgid].empty?

      @entries << Entry.new(entry)
    end
    # rubocop:enable Style/SafeNavigation

    def add_header_entry(entry)
      raise('Duplicate entry, header was already instantiated') if @header

      @header = Header.new(Entry.new(entry))
    end
  end
end
