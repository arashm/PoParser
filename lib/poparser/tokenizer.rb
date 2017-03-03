module PoParser
  # Feed each block of PO file to Parser.
  class Tokenizer
    def initialize
      @po = Po.new
    end

    def extract_entries(path)
      @po.path = path
      File.open(path, 'r').each_line("\n\n") do |block|
        block.strip!
        @po << parse_block(block) if block != ''
      end
      @po
    end

  private
    def parse_block(block)
      hash = SimplePoParser.parse_message(block)
    end
  end
end
