module PoParser
	class PoParserError < StandardError
	end

	class PoSyntaxError < PoParserError
		@msg = ""
		def initialize(msg="Invalid po syntax")
			@msg = msg
			super(msg)
		end

	end
end
