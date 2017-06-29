# External Libs
require 'simple_po_parser'

# Local files
require_relative 'poparser/constants'
require_relative 'poparser/tokenizer'
require_relative 'poparser/comment'
require_relative 'poparser/message'
require_relative 'poparser/header'
require_relative 'poparser/entry'
require_relative 'poparser/po'
require_relative 'poparser/version'

module PoParser
  class << self
    def parse(payload)
      if File.exist?(payload)
        Kernel.warn 'DEPRICATION WARNING: `parse` only accepts content of a '\
          'PO file as a string and this behaviour will be removed on next '\
          'major release. Use `parse_file` instead.'
        parse_file(payload)
      else
        Tokenizer.new.extract(payload)
      end
    end

    def parse_file(path)
      Tokenizer.new(true).extract(path)
    end
  end
end
