module PoParser
  # Converts the array returned from {Parser} to a useable hash
  class Transformer < Parslet::Transform
    RULES = %i(translator_comment refrence extracted_comment flag previous_untraslated_string
      msgid msgid_plural msgstr msgstr_plural msgctxt)

    RULES.each do |rule_name|
      rule(rule_name => simple(:val)) { {"#{rule_name}".to_sym => val.to_s.chomp } }
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
