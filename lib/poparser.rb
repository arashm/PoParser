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
    def parse(path)
      Tokenizer.new.extract_entries(path)
    end
  end
end
