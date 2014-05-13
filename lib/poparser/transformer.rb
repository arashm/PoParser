module PoParser
  # Converts the array returned from {Parser} to a useable hash
  class Transformer < Parslet::Transform
    LABELS.each do |rule_name|
      rule(rule_name => subtree(:val)) { {"#{rule_name}".to_sym => val[:text].to_s.chomp } }
    end

    def initialize
      @hash = {}
      super
    end

    def transform obj
      apply(obj).each do |hash|
        merge(hash)
      end
      @hash
    end

    private

    def merge(newh)
      @hash.merge!(newh) do |key, oldval, newval|
        if oldval.is_a? Array
          oldval << newval
        else
          Array.new [oldval, newval]
        end
      end
    end

  end
end
