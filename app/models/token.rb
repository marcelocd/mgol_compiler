class Token
	attr_accessor :index, :token_class, :lexeme, :type

	def initialize args
    @order = args[:order]
    @token_class = args[:token_class]
    @lexeme = args[:lexeme]
    @type = args[:type]
	end
end
