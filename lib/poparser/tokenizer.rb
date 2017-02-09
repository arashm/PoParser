module PoParser
  # Feed each block of PO file to Parser.
  class Tokenizer
    def initialize
      @parser = Parser.new
      @po     = Po.new
    end

    def extract_entries(path)
      @po.path = path
      block = ''
      File.open(path, 'r').each_line("\n\n") do |block|
        block.strip!
        puts block
        @po << parse_block(block) if block != ''
      end
      @po
    end

  private
    def parse_block(block)
      parsed_hash = @parser.parse(block)
      Transformer.new.transform(parsed_hash)
    end
  end
end
