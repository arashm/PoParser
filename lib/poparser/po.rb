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
      if entry.kind_of? Hash
        import_hash(entry)
      elsif entry.kind_of? Array
        import_array(entry)
      else
        raise ArgumentError, 'Must be a hash or an array of hashes'
      end
      self
    end
    alias_method :<<, :add

    # Returns an array of all entries in po file
    #
    # @param include_obsolete [Boolean] Whether include obsolete entries or not
    # @return [Array]
    def entries(include_obsolete=false)
      if include_obsolete
        @entries
      else
        find_all do |entry|
          !entry.obsolete?
        end
      end
    end
    alias_method :all, :entries

    # Finds all entries that are flaged as fuzzy
    #
    # @return [Array] an array of fuzzy entries
    def fuzzy
      find_all do |entry|
        entry.fuzzy?
      end
    end

    # Finds all entries that are untranslated
    #
    # @return [Array] an array of untranslated entries
    def untranslated
      find_all do |entry|
        entry.untranslated?
      end
    end

    # Finds all entries that are translated
    #
    # @return [Array] an array of translated entries
    def translated
      find_all do |entry|
        entry.translated?
      end
    end

    # Finds all obsolete entries
    #
    # @return [Array] an array of obsolete entries
    def obsolete
      find_all do |entry|
        entry.obsolete?
      end
    end
    alias_method :cached, :obsolete

    # Count of all entries without counting obsolete entries
    #
    # @return [String]
    def size
      entries.length
    end
    alias_method :length, :size

    # Search for entries with provided string
    #
    # @param label [Symbol] One of the known LABELS
    # @param string [String] String to search for
    # @return [Array] Array of matched entries
    def search_in(label, string)
      if !LABELS.include? label.to_sym
        raise ArgumentError, "Unknown key: #{label}"
      end

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
        translated:   percentage(translated_size),
        untranslated: percentage(untranslated_size),
        fuzzy:        percentage(fuzzy_size)
      }
    end

    # Converts Po file to an hashes of entries
    #
    # @return [Array] array of hashes of entries
    def to_h
      array = []
      array << @header.to_h if @header
      @entries.each do |entry|
        array << entry.to_h
      end
      array
    end

    # Shows a String representation of the Po file
    #
    # @return [String]
    def to_s
      array = []
      array << @header.to_s if @header
      # add a blank line after header
      array << ""
      @entries.each do |entry|
        array << entry.to_s
      end
      array.join("\n")
    end

    # Saves the file to the provided path
    def save_file
      raise ArgumentError, 'Need a Path to save the file' if @path.nil?
      File.open(@path, 'w') do |f|
        f.write to_s
      end
    end

    def each
      @entries.each do |entry|
        yield entry
      end
    end

    def inspect
      "<#{self.class.name}, Translated: #{translated.length}(#{stats[:translated]}%) Untranslated: #{untranslated.length}(#{stats[:untranslated]}%) Fuzzy: #{fuzzy.length}(#{stats[:fuzzy]}%)>"
    end

  private
    # calculates percentages based on total number of entries
    #
    # @param [Integer] number of entries
    # @return [Float] percentage of the provided entries
    def percentage(count)
      ((count.to_f / self.size) * 100).round(1)
    end

    def import_hash(entry)
      add_entry(entry)
    end

    def import_array(entry)
      entry.each do |en|
        add_entry(en)
      end
    end

    def add_entry(entry)
      if entry[:msgid] && entry[:msgid].length == 0
        raise(RuntimeError, "Duplicate entry, header was already instantiated") if @header != nil
        @header = Header.new(Entry.new(entry))
      else
        @entries << Entry.new(entry)
      end
    end
  end
end
