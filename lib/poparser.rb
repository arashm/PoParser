# External Libs
require 'simple_po_parser'

# Local files
require 'poparser/constants'
require 'poparser/tokenizer'
require 'poparser/comment'
require 'poparser/message'
require 'poparser/header'
require 'poparser/entry'
require 'poparser/po'
require 'poparser/version'

module PoParser
  class << self
    def parse(path)
      Tokenizer.new.extract_entries(path)
    end
  end
end
