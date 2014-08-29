require 'ap'

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
      File.open(path, 'r') do |f|
        f.each_line do |line|
          if line.match(/^\n$/)
            @po << parse_block(block)
            block = ''
          elsif f.eof?
            block += line
            @po << parse_block(block)
          else
            block += line
          end
        end
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
