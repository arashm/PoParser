module PoParser
  # Po class keeps all entries of a Po file
  # 
  class Po
    include Enumerable
    attr_reader :entries
    attr_accessor :path
    alias_method :all, :entries

    def initialize(args = {})
      @entries = []
      @path    = args.fetch(:path, nil)
    end

    # add new entries to po file
    # 
    # @example
    #   entry = { 
    #             translator_comment: 'comment',
    #             refrence: 'refrense comment',
    #             flag: 'fuzzy',
    #             msgstr: 'translatable string',
    #             msgstr: 'translation'
    #           }
    #   add_entry(entry)
    # 
    # @param entry [Hash, Array] a hash of entry contents or an array of hashes
    def add_entry(entry)
      if entry.kind_of? Hash
        @entries << Entry.new(entry)
        @entries.last
      elsif entry.kind_of? Array
        entry.each do |en|
          @entries << Entry.new(en)
        end
      else
        raise ArgumentError, 'Must be a hash or an array of hashes'
      end
    end
    alias_method :<<, :add_entry

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

    # Shows statistics and status of the provided file in percentage.
    # 
    # @return [Hash] a hash of translated, untranslated and fuzzy percentages
    def stats
      untranslated_size = untranslated.size
      translated_size = translated.size
      fuzzy_size = fuzzy.size

      {
        translated: percentage(translated_size),
        untranslated: percentage(untranslated_size),
        fuzzy: percentage(fuzzy_size)
      }
    end

    # Converts Po file to an hashes of entries
    # 
    # @return [Array] array of hashes of entries
    def to_h
      array = []
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
      "<#{self.class.name}, Translated: #{stats[:translated]}% Untranslated: #{stats[:untranslated]}% Fuzzy: #{stats[:fuzzy]}%>"
    end

  private
    # calculates percentages based on total number of entries
    # 
    # @param [Integer] number of entries
    # @return [Float] percentage of the provided entries
    def percentage(size)
      total = @entries.size
      ((size.to_f / total) * 100).round(1)
    end
  end
end
