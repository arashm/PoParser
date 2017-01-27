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
        parsed_hash = @parser.parse_with_debug(block)
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

  namespace :improve do
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
          parsed_hash = @parser.parse_with_debug(block)
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
          parsed_hash = @parser.parse_with_debug(block)
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

  end # end of improve namespace

end # end of benchmark namespace
