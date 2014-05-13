require 'ap'

module PoParser
  # Feed each block of PO file to Parser.
  class Tokenizer
    def initialize
      @parser = Parser.new
      @po     = Po.new
    end

    def extract_entries(path)
      block = ''
      File.open(path, 'r') do |f|
        f.each_line do |line|
          unless line.match("^\n") || f.eof?
            block += line
          else
            parsed_hash = @parser.parse(block)
            transformed = Transformer.new.transform(parsed_hash)
            @po << transformed
            block = ''
          end
        end
      end
      @po
    end

  end
end
