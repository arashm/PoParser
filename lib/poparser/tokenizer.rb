module PoParser
  # Feed each block of PO file to Parser.
  class Tokenizer
    def initialize(is_file = false)
      @po = Po.new
      @is_file = is_file
    end

    def extract(payload)
      if @is_file
        @po.path = payload
        payload = File.read(payload, mode: 'r:utf-8')
      end

      extract_entries(payload)
    end

  private

    def parse_block(block)
      SimplePoParser.parse_message(block)
    end

    def extract_entries(payload)
      payload.split("\n\n").each do |block|
        block.strip!
        @po << parse_block(block) if block != ''
      end

      @po
    end
  end
end
