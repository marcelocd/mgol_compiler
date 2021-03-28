class CompilerController < ActionController::Base
  def home
    params = { token_class: 'id',
               lexeme: 'test',
               type: nil }

    @token = Token.new(params)
  end
end
