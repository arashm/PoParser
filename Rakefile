require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'geminabox-release'
GeminaboxRelease.patch(:use_config => true, :remove_release => true)

desc "Generate a random po file. Takes optional rake args for number of entries"
task 'generate_random_pofile', :messages, :obsoletes do |t, args|
  args.with_defaults(:messages => "200", :obsoletes => "10")
  require_relative 'spec/utils/random_pofile_generator'
  PoParser::RandomPoFileGenerator.generate_file(
    File.expand_path("test/benchmark.po", __dir__), args[:messages].to_i, args[:obsoletes].to_i
  )
end

namespace :debug do
  desc "Raw output of small benchmark file"
  task 'parse_raw' do
    PoParser::Tokenizer.class_eval do
      # monkey patch tokenizer so it only parses, no PO object generation
      def initialize
        @parser = PoParser::ImprovedParser.new
      end

      def extract_entries(path)
        File.open(path, 'r').each_line("\n\n") do |block|
          puts parse_block(block.strip)
        end
        true
      end

      private
      def parse_block(block)
        # only print the first error
        begin
          parsed_hash = @parser.parse(block)
          parsed_hash = PoParser::Transformer.new.transform(parsed_hash)
          puts "Hash:"
          puts parsed_hash
        rescue Parslet::ParseFailed => error
          puts "Message:"
          puts block
          puts "Error:"
          puts error.cause.ascii_tree
          exit
        end
        #parsed_hash = @parser.parse_with_debug(block)
      end
    end

    pofile = File.expand_path("test/benchmark_small.po", __dir__)
    PoParser.parse(pofile)
  end

  desc "Debug small benchmark file"
  task 'parse_small' do
    require 'parslet/convenience'
    Parslet::Atoms::Context.class_eval do
      def lookup(obj, pos)
        p obj
        @cache[pos][obj.object_id]
      end
    end

    PoParser::Tokenizer.class_eval do
      # monkey patch tokenizer so it only parses, no PO object generation
      def initialize
        @parser = PoParser::ImprovedParser.new
      end

      def extract_entries(path)
        File.open(path, 'r').each_line("\n\n") do |block|
          puts parse_block(block.strip)
        end
        true
      end

      private
      def parse_block(block)
        # only print the first error
        begin
          parsed_hash = @parser.parse(block)
          parsed_hash = PoParser::Transformer.new.transform(parsed_hash)
          puts "Hash:"
          puts parsed_hash
        rescue Parslet::ParseFailed => error
          puts "Message:"
          puts block
          puts "Error:"
          puts error.cause.ascii_tree
          exit
        end
        #parsed_hash = @parser.parse_with_debug(block)
      end
    end

    pofile = File.expand_path("test/benchmark_small.po", __dir__)
    PoParser.parse(pofile)
  end
end

namespace :benchmark do
  require 'benchmark'
  require 'poparser'

  desc "Benchmark of 10 full PoParser runs of test/benchmark.po"
  task 'full' do
    pofile = File.expand_path("test/benchmark.po", __dir__)
    Benchmark.bmbm do |x|
      x.report("PoParser:") {10.times { PoParser.parse(pofile) }}
    end
  end

  desc "Generate 5 random PO files with 100 to 500 messages and benchmark each full PoParser run"
  task 'five_random_po_full' do
    include Benchmark
    require_relative 'spec/utils/random_pofile_generator'
    pofile = File.expand_path("test/benchmark.po.tmp", __dir__)
    Benchmark.benchmark(CAPTION, 6, FORMAT, "total:") do |x|
      total = nil
      total_length = 0
      for i in 0..5 do
        length = (Random.new.rand * 400.0 + 100).to_i
        total_length += length
        puts "Benchmarking file of length #{length}"
        PoParser::RandomPoFileGenerator.generate_file(pofile, length)
        t = x.report("try#{i}:") {PoParser.parse(pofile)}
        File.unlink(pofile)
        total = total ? total+t : t
      end
      puts "Total message length #{total_length}"
      [total]
    end
  end

  desc "Benchmark only parslet speed of parsing test/benchmark.po 10 times"
  task 'parse' do
    # Parslet::Atoms::Context.class_eval do
    #   def lookup(obj, pos)
    #     p obj
    #     @cache[pos][obj.object_id]
    #   end
    # end

    PoParser::Tokenizer.class_eval do
      # monkey patch tokenizer so it only parses, no PO object generation
      def initialize
        @parser = PoParser::Parser.new
      end

      def extract_entries(path)
        block = ''
        File.open(path, 'r') do |f|
          f.each_line do |line|
            if line.match(/^\n$/)
              parse_block(block) if block != ''
              block = ''
            elsif f.eof?
              block += line
              parse_block(block)
            else
              block += line
            end
          end
        end
        true
      end
      private
      def parse_block(block)
        parsed_hash = @parser.parse(block)
      end
    end

    pofile = File.expand_path("test/benchmark.po", __dir__)
    Benchmark.bmbm do |x|
      x.report("parse:") {10.times {PoParser.parse(pofile)}}
    end
  end

  desc "Benchmark only parslet speed of parsing test/benchmark.po 10 times with debug"
  task 'parse_with_debug' do
    require 'parslet/convenience'
    $lookup_count = 0
    $parsing_count = 0
    $char_count = 0
    Parslet::Atoms::Context.class_eval do
      def lookup(obj, pos)
        # p obj
        $lookup_count += 1
        @cache[pos][obj.object_id]
      end
    end

    PoParser::Tokenizer.class_eval do
      # monkey patch tokenizer so it only parses, no PO object generation
      def initialize
        @parser = PoParser::Parser.new
      end

      def extract_entries(path)
        File.open(path, 'r').each_line("\n\n") do |block|
          block.strip!
          $char_count += block.length
          parse_block(block)
        end
        true
      end

      private
      def parse_block(block)
        $parsing_count += 1
        # only print the first error
        begin
          parsed_hash = @parser.parse(block)
        rescue Parslet::ParseFailed => error
          puts "Message:"
          puts block
          puts "Error:"
          puts error.cause.ascii_tree
          exit
        end
        #parsed_hash = @parser.parse_with_debug(block)
      end
    end

    pofile = File.expand_path("test/benchmark.po", __dir__)
    Benchmark.bmbm do |x|
      x.report("debug:") {2.times { PoParser.parse(pofile) }}
    end
    lookups_per_parse = ($lookup_count / $parsing_count.to_f).to_f.round(1);
    lookups_per_parse = lookups_per_parse.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    lookups_per_char = ($lookup_count / $char_count.to_f).to_f.round(2);
    lookups_per_char = lookups_per_char.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    $lookup_count = $lookup_count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    $parsing_count = $parsing_count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    $char_count = $char_count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    puts "Number of lookups required: #{$lookup_count} in #{$parsing_count} parses with #{$char_count} chars"
    puts "Thats #{lookups_per_parse} lookups per parse and #{lookups_per_char} lookups per char"
  end

  desc "Benchmark file reading speed"
  task 'read_file' do
    PoParser::Tokenizer.class_eval do
      # monkey patch tokenizer so it only parses, no PO object generation
      def initialize
        @parser = PoParser::Parser.new
      end

      def extract_entries(path)
        block = ''
        File.open(path, 'r') do |f|
          f.each_line do |line|
            if line.match(/^\n$/)
              block = ''
            elsif f.eof?
              block += line
            else
              block += line
            end
          end
        end
        true
      end
    end

    pofile = File.expand_path("test/benchmark.po", __dir__)
    Benchmark.bmbm do |x|
      x.report("read file:") {1000.times { PoParser.parse(pofile) }}
    end
  end


  desc "Profile parse"
  task "profile_parse" do
    PoParser::Tokenizer.class_eval do
      # monkey patch tokenizer so it only parses, no PO object generation
      def initialize
        @parser = PoParser::Parser.new
      end

      def extract_entries(path)
        block = ''
        File.open(path, 'r') do |f|
          f.each_line do |line|
            if line.match(/^\n$/)
              parse_block(block) if block != ''
              block = ''
            elsif f.eof?
              block += line
              parse_block(block)
            else
              block += line
            end
          end
        end
        true
      end
      private
      def parse_block(block)
        parsed_hash = @parser.parse(block)
      end
    end
    require 'ruby-prof'
    RubyProf.start
    pofile = File.expand_path("test/benchmark.po", __dir__)
    PoParser.parse(pofile)
    result = RubyProf.stop

    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)
  end

  namespace :improve do
    require_relative 'lib/poparser/improved_parser'
    # override some benchmarks improving the monkey patched methods to compare
    desc "Benchmark only parslet speed of parsing test/benchmark.po 10 times"
    task 'parse' do
      # Parslet::Atoms::Context.class_eval do
      #   def lookup(obj, pos)
      #     p obj
      #     @cache[pos][obj.object_id]
      #   end
      # end

      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
          @parser = PoParser::ImprovedParser.new
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block.strip)
          end
          true
        end

        private
        def parse_block(block)
          parsed_hash = @parser.parse(block)
        end
      end

      pofile = File.expand_path("test/benchmark.po", __dir__)
      Benchmark.bmbm do |x|
        x.report("improved:") {10.times { PoParser.parse(pofile) }}
      end
    end

    desc "Bench with debug"
    task 'parse_with_debug' do
      require 'parslet/convenience'
      $lookup_count = 0
      $parsing_count = 0
      $char_count = 0
      Parslet::Atoms::Context.class_eval do
        def lookup(obj, pos)
          # p obj
          $lookup_count += 1
          @cache[pos][obj.object_id]
        end
      end

      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
          @parser = PoParser::ImprovedParser.new
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            block.strip!
            $char_count += block.length
            parse_block(block)
          end
          true
        end

        private
        def parse_block(block)
          $parsing_count += 1

          # only print the first error
          begin
            parsed_hash = @parser.parse(block)
          rescue Parslet::ParseFailed => error
            puts "Message:"
            puts block
            puts "Error:"
            puts error.cause.ascii_tree
            exit
          end
          # parsed_hash = @parser.parse_with_debug(block)
        end
      end

      pofile = File.expand_path("test/benchmark.po", __dir__)
      Benchmark.bmbm do |x|
        x.report("debug:") {2.times { PoParser.parse(pofile) }}
      end
      lookups_per_parse = ($lookup_count / $parsing_count.to_f).to_f.round(1);
      lookups_per_parse = lookups_per_parse.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      lookups_per_char = ($lookup_count / $char_count.to_f).to_f.round(2);
      lookups_per_char = lookups_per_char.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      $lookup_count = $lookup_count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      $parsing_count = $parsing_count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      $char_count = $char_count.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      puts "Number of lookups required: #{$lookup_count} in #{$parsing_count} parses with #{$char_count} chars"
      puts "Thats #{lookups_per_parse} lookups per parse and #{lookups_per_char} lookups per char"
    end


    desc "Bench benchmark/small with debug"
    task 'parse_small_with_debug' do
      require 'parslet/convenience'
      # Parslet::Atoms::Context.class_eval do
      #   def lookup(obj, pos)
      #     p obj
      #     @cache[pos][obj.object_id]
      #   end
      # end

      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
          @parser = PoParser::ImprovedParser.new
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block.strip)
          end
          true
        end

        private
        def parse_block(block)
          # only print the first error
          begin
            parsed_hash = @parser.parse(block)
            parsed_hash = PoParser::Transformer.new.transform(parsed_hash)
            puts "Hash:"
            puts parsed_hash
          rescue Parslet::ParseFailed => error
            puts "Message:"
            puts block
            puts "Error:"
            puts error.cause.ascii_tree
            exit
          end
          #parsed_hash = @parser.parse_with_debug(block)
        end
      end

      pofile = File.expand_path("test/benchmark_small.po", __dir__)
      Benchmark.bmbm do |x|
        x.report("debug s:") {2.times { PoParser.parse(pofile) }}
      end
    end

    # override some benchmarks improving the monkey patched methods to compare
    desc "Compare benchmark of parslet original and improved parsing speed of test/benchmark.po 10 times"
    task 'parse_compare' do

      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block.strip)
          end
          true
        end

        private
        def parse_block(block)
          parsed_hash = @parser.parse(block)
        end
      end

      include Benchmark
      pofile = File.expand_path("test/benchmark.po", __dir__)
      Benchmark.benchmark(CAPTION, 10, FORMAT, "default:" , "improved:") do |x|
        PoParser::Tokenizer.class_eval do
          def initialize
            @parser = PoParser::Parser.new
          end
        end
        d1 = x.report("default1:") {10.times { PoParser.parse(pofile) }}
        PoParser::Tokenizer.class_eval do
          def initialize
            @parser = PoParser::ImprovedParser.new
          end
        end
        i1 = x.report("improved1:") {10.times { PoParser.parse(pofile) }}
        PoParser::Tokenizer.class_eval do
          def initialize
            @parser = PoParser::Parser.new
          end
        end
        d2 = x.report("default2:") {10.times { PoParser.parse(pofile) }}
        PoParser::Tokenizer.class_eval do
          def initialize
            @parser = PoParser::ImprovedParser.new
          end
        end
        i2= x.report("improved2:") {10.times { PoParser.parse(pofile) }}
        [d1+d2, i1+i2]
      end
    end

    desc "Benchmark file reading speed"
    task 'read_file' do
      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
          @parser = PoParser::Parser.new
        end

        def extract_entries(path)
          block = ''
          File.open(path, 'r').each_line("\n\n") do |line|
            block = line.strip
          end
          true
        end
      end

      pofile = File.expand_path("test/benchmark.po", __dir__)
      Benchmark.bmbm do |x|
        x.report("read file:") {1000.times { PoParser.parse(pofile) }}
      end
    end

    desc "Profile parse"
    task "profile_parse" do
      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
          @parser = PoParser::ImprovedParser.new
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block.strip)
          end
          true
        end

        private
        def parse_block(block)
          parsed_hash = @parser.parse(block)
        end
      end

      require 'ruby-prof'
      RubyProf.start
      pofile = File.expand_path("test/benchmark.po", __dir__)
      PoParser.parse(pofile)
      result = RubyProf.stop

      printer = RubyProf::FlatPrinter.new(result)
      printer.print(STDOUT)
    end

  end # end of improve namespace

  desc "case if/else send bench"
  task "caseifsend" do
    n = 5000000

    def a(char)
      char
    end
    def b(char)
      char
    end
    def c(char)
      char
    end
    def d(char)
      char
    end

    Benchmark.bmbm do |x|
      char = 'b'
      x.report("case:") {n.times {
        case char
        when 'c'
          c(char)
        when 'b'
          b(char)
        when 'a'
          a(char)
        when 'd'
          d(char)
        else
        end
        }}
        x.report("if/else:") {n.times {
          if char == 'c'
            c(char)
          elsif char == 'b'
            b(char)
          elsif char == 'a'
            a(char)
          elsif char == 'd'
            d(char)
          else
          end
          }}
        x.report("send:") {n.times {
          self.send char.to_sym, char
          }}
    end
  end

  desc "benchmark scan vs getch performance"
  task "strscan_scan_vs_getch" do
    string = '""'
    require 'strscan'

    n = 100000
    Benchmark.bmbm do |x|

      x.report("scan:") {
        n.times {
          scanner = StringScanner.new(string)
          loop do
            if scanner.scan(/"/)
              result = "yolo"
            else
              scanner.pos = scanner.pos + 1
            end
            break if scanner.eos?
          end
        }
      }
      x.report("getch:") {
        n.times {
          scanner = StringScanner.new(string)
          loop do
            if scanner.getch == ""
              result = "yolo"
            end
            break if scanner.eos?
          end
        }
      }

    end
  end

  desc "benchmark escaped performance of stringscanner"
  task "strscan_escaped" do
    string = File.read(File.expand_path("test/escape_string.txt", __dir__))
    require 'strscan'
    UNESCAPED_QUOTE_REGEX = /(?<!\\)(?:\\{2})*"/

    ANYTHING_BUT_UNESCAPED_QUOTE = /((\\{2})|(\\")|[^"])*/
    ANYTHING_BUT_3 = /(\\(\\|")|[^"])*/
    ANYTHING_BUT_2 = /(((?<!\\)(?:\\{2})*\\")|[^"])*/


    scanner = StringScanner.new(string)
    puts scanner.scan_until(UNESCAPED_QUOTE_REGEX)
    scanner = StringScanner.new(string)
    puts scanner.scan(ANYTHING_BUT_UNESCAPED_QUOTE)
    scanner = StringScanner.new(string)
    puts scanner.scan(ANYTHING_BUT_2)
    scanner = StringScanner.new(string)
    puts scanner.scan(ANYTHING_BUT_3)
    n = 100000
    Benchmark.bmbm do |x|
      x.report("until:") {
        n.times {
          scanner = StringScanner.new(string)
          result = scanner.scan_until(UNESCAPED_QUOTE_REGEX).chomp('"')
          scanner.pos = scanner.pos - 1
        }
      }

      x.report("scan:") {
        n.times {
          scanner = StringScanner.new(string)
          result = scanner.scan(ANYTHING_BUT_UNESCAPED_QUOTE)
        }
      }
      x.report("scan2:") {
        n.times {
          scanner = StringScanner.new(string)
          result = scanner.scan(ANYTHING_BUT_2)
        }
      }
      x.report("scan3:") {
        n.times {
          scanner = StringScanner.new(string)
          result = scanner.scan(ANYTHING_BUT_3)
        }
      }

      x.report("bychar:"){
        n.times {
          scanner = StringScanner.new(string)
          result = ""
        while true
          char = scanner.getch
          if char == "\\"
            result << '\\'
            result << scanner.getch
          elsif char == "\""
            break
          else
            result << char
          end
        end
        }
      }

    end

  end

  desc "benchmark scan vs scan_until performance of stringscanner"
  task "strscan_scan_vs_until" do
    string = File.read(File.expand_path("test/escape_string.txt", __dir__))
    require 'strscan'

    scanner = StringScanner.new(string)
    puts scanner.scan(/.*/)
    scanner = StringScanner.new(string)
    puts scanner.scan_until(/$/)
    n = 1000000
    def scan(scanner)
      scanner.scan(/.*/).rstrip
    end
    def scan!(scanner)
      result = scanner.scan(/.*/)
      result.rstrip!
      result
    end
    Benchmark.bmbm do |x|
      x.report("until:") {
        n.times {
          scanner = StringScanner.new(string)
          result = scanner.scan_until(/\p{Blank}*$/)
        }
      }

      x.report("scan:") {
        n.times {
          scanner = StringScanner.new(string)
          scan(scanner)
        }
      }
      x.report("scan!:") {
        n.times {
          scanner = StringScanner.new(string)
          scan!(scanner)
        }
      }
    end
  end

  desc "benchmark scan with and without rescue block"
  task "strscan_scan_rescue_block" do
    string = File.read(File.expand_path("test/escape_string.txt", __dir__))
    require 'strscan'

    scanner = StringScanner.new(string)
    puts scanner.scan(/.*/)
    scanner = StringScanner.new(string)
    puts scanner.scan_until(/$/)
    n = 1000000
    def scan(scanner)
      scanner.scan(/.*/).rstrip
    end
    def rescue_scan(scanner)
      begin
        scanner.scan(/.*/).rstrip
      rescue PoParserError => pe
        raise PoParserError
      end
    end

    Benchmark.bmbm do |x|
      x.report("scan:") {
        n.times {
          scanner = StringScanner.new(string)
          scan(scanner)
        }
      }
      x.report("rescue:") {
        n.times {
          scanner = StringScanner.new(string)
          rescue_scan(scanner)
        }
      }
    end
    n = 10000000
    Benchmark.bmbm do |x|
      x.report("rand w/o rescue:") {
        r = Random.new(1)
        n.times {
          r.rand(1000) * r.rand(1000)
        }
      }
      x.report("rand w rescue:") {
        r = Random.new(1)
        n.times {
          begin
            r.rand(1000) * r.rand(1000)
          rescue StandardError => e
            raise StandardError
          end
        }
      }
    end
  end
end # end of benchmark namespace

namespace :fastparser do
    desc "Test fast parser with single complex entry"
    task "test" do
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'

      puts "test/complex_entry.po output:"
      puts PoParser::FastParser.parse(File.read(File.expand_path("test/complex_entry.po", __dir__)))

      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
          @po = PoParser::Po.new
        end

        private
        def parse_block(block)
          parsed_hash = PoParser::FastParser.parse(block)
        end
      end

      po = PoParser.parse(File.expand_path("test/benchmark_small.po",__dir__))
      puts po.inspect
    end

    desc "Print output of old parser and new parser for comparison"
    task "compare_output" do
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'

      entry = File.read(File.expand_path("test/complex_entry.po", __dir__))

      puts "Old parser:"
      raw = PoParser::Parser.new.parse(entry.strip)
      puts PoParser::Transformer.new.transform(raw)

      puts "Fast parser:"
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'
      entry = File.read(File.expand_path("test/complex_entry.po", __dir__))
      puts PoParser::FastParser.parse(entry)
    end

    desc "Compare new and old parser result on test/benchmark.po"
    task "compare" do
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'
      file = File.expand_path("test/benchmark.po", __dir__)

      puts "Old parser:"
      old_po = PoParser.parse(file)

      PoParser::Tokenizer.class_eval do
        def extract_entries(path)
          @po.path = path
          block = ''
          File.open(path, 'r').each_line("\n\n") do |block|
            @po << parse_block(block) if block != ''
          end
          @po
        end
        private
        def parse_block(block)
          parsed_hash = PoParser::FastParser.parse(block)
        end
      end

      puts "Fast parser:"
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'
      new_po = PoParser.parse(file)


      puts "Equal output?: #{old_po.to_s === new_po.to_s}"

    end

    desc "Profile fastparser"
    task "profile" do
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'
      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block.strip)
          end
          true
        end

        private
        def parse_block(block)
          parsed_hash = PoParser::FastParser.parse(block)
        end
      end

      require 'ruby-prof'
      RubyProf.start
      pofile = File.expand_path("test/benchmark.po", __dir__)
      PoParser.parse(pofile)
      result = RubyProf.stop

      printer = RubyProf::FlatPrinter.new(result)
      printer.print(STDOUT)
    end

    desc "Benchmark only parsing speed of parsing test/benchmark.po 10 times"
    task 'benchmark_parse' do
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'
      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block)
          end
          true
        end
        private
        def parse_block(block)
          parsed_hash = PoParser::FastParser.parse(block)
        end
      end

      pofile = File.expand_path("test/benchmark.po", __dir__)
      Benchmark.bmbm do |x|
        x.report("parse:") {10.times {PoParser.parse(pofile)}}
      end
    end


    desc "Benchmark"
    task "benchmark" do
      require_relative 'lib/poparser/error'
      require_relative 'lib/poparser/fast_parser'
      PoParser::Tokenizer.class_eval do
        # monkey patch tokenizer so it only parses, no PO object generation
        def initialize
        end

        def extract_entries(path)
          File.open(path, 'r').each_line("\n\n") do |block|
            parse_block(block)
          end
          true
        end
        private
        def parse_block(block)
          parsed_hash = PoParser::FastParser.parse(block)
        end
      end
      include Benchmark
      require_relative 'spec/utils/random_pofile_generator'
      pofile = File.expand_path("test/benchmark.po.tmp", __dir__)
      Benchmark.benchmark(CAPTION, 6, FORMAT, "total:") do |x|
        total = nil
        total_length = 0
        for i in 0..5 do
          length = (Random.new.rand * 400.0 + 100).to_i
          total_length += length
          puts "Benchmarking file of length #{length}"
          PoParser::RandomPoFileGenerator.generate_file(pofile, length)
          t = x.report("try#{i}:") {PoParser.parse(pofile)}
          File.unlink(pofile)
          total = total ? total+t : t
        end
        puts "Total message length #{total_length}"
        [total]
      end
    end

    desc "compare new parser to old parser in benchmark"
    task "compare_benchmark" do
      include Benchmark
      pofile = File.expand_path("test/benchmark.po", __dir__)
      Benchmark.benchmark(CAPTION, 14, FORMAT, "default total:" , "fast total:") do |x|
        PoParser::Tokenizer.class_eval do
          def initialize
            @parser = PoParser::Parser.new
          end
          def extract_entries(path)
            File.open(path, 'r').each_line("\n\n") do |block|
              parse_block(block.strip)
            end
            true
          end

          private
          def parse_block(block)
            parsed_hash = @parser.parse(block)
          end
        end
        d1 = x.report("default1:") {100.times { PoParser.parse(pofile) }}
        PoParser::Tokenizer.class_eval do
          def initialize

          end

          def extract_entries(path)
            File.open(path, 'r').each_line("\n\n") do |block|
              parse_block(block)
            end
            true
          end

          private
          def parse_block(block)
            parsed_hash = PoParser::FastParser.parse(block)
          end
        end
        i1 = x.report("fast1:") {100.times { PoParser.parse(pofile) }}
        PoParser::Tokenizer.class_eval do
          def initialize
            @parser = PoParser::Parser.new
          end
          def extract_entries(path)
            File.open(path, 'r').each_line("\n\n") do |block|
              parse_block(block.strip)
            end
            true
          end

          private
          def parse_block(block)
            parsed_hash = @parser.parse(block)
          end
        end
        d2 = x.report("default2:") {100.times { PoParser.parse(pofile) }}
        PoParser::Tokenizer.class_eval do
          def initialize

          end

          def extract_entries(path)
            File.open(path, 'r').each_line("\n\n") do |block|
              parse_block(block)
            end
            true
          end

          private
          def parse_block(block)
            parsed_hash = PoParser::FastParser.parse(block)
          end
        end
        i2= x.report("fast2:") {100.times { PoParser.parse(pofile) }}
        [d1+d2, i1+i2]
      end
    end
end
