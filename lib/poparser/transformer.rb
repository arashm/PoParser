module PoParser
  # Converts the array returned from {Parser} to a usable hash
  class Transformer
    def initialize
      @hash = {}
      super
    end

    def transform(obj)
      apply_transforms(obj).each do |hash|
        merge(hash)
      end
      @hash
    end

  private
    # @Note: There was a problem applying all rules together. I don't know
    #   in what order Parslet run rules, but it's not in order. I ended up
    #   making two separate transform and feed one output to the other.
    def first_transform
      Parslet::Transform.new do
        rule(:msgstr_plural => subtree(:plural)) do
          if plural.is_a? Array
            { "msgstr\[#{plural[0][:plural_id]}\]".to_sym => plural }
          else
            { "msgstr\[#{plural[:plural_id]}\]".to_sym => plural }
          end
        end

        rule(:text => simple(:txt)) { txt.to_s.chomp }
      end
    end

    def second_transform
      Parslet::Transform.new do
        rule(:plural_id => simple(:id), :text => simple(:txt)) { txt }
      end
    end

    def apply_transforms(hash)
      first  = first_transform.apply(hash)
      second_transform.apply(first)
    end

    # Merges two hashed together. If both hashes have common keys it
    # will create an array of them
    #
    # @return [Hash]
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
