class ErrorHelper
  attr_accessor :code, :line, :column, :guilty_character

	def initialize args = {}
    @code = args[:code]
    @line = args[:line]
    @column = args[:column]
    @guilty_character = args[:guilty_character]
	end
end
