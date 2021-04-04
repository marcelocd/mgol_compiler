class Token
	attr_accessor :token_class, :lexeme, :type

	def initialize args = {}
    @token_class = args[:token_class]
    @lexeme = args[:lexeme]
    @type = args[:type]
	end
end
