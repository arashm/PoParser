module PoParser
	class PoParserError < StandardError
	end

	class PoSyntaxError < PoParserError
	end
end
