# External Libs
require 'parslet'

# Local files
require 'poparser/constants'
require 'poparser/parser'
require 'poparser/improved_parser'
require 'poparser/transformer'
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
