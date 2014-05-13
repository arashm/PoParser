require 'ap'

module PoParser
  # Feed each block of PO file to Parser.
  class Tokenizer
    def initialize
      @parser = Parser.new
    end

    def extract_blocks(path)
      block = ''
      arr = []
      id = 1
      File.open(path, 'r') do |f|
        f.each_line do |line|
          unless line.match("^\n") || f.eof?
            block += line
          else
            parsed_hash = @parser.parse(block)
            transformed = Transformer.new.transform(parsed_hash).merge!({id: id})
            arr << transformed
            block = ''
            id += 1
          end
        end
        arr
      end
    end

  end
end
