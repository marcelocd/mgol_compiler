class ErrorHelper
  attr_accessor :code, :line, :column, :guilty_character

  UNEXPECTED_CHARACTER_ERROR_CODE = 1
  MISSING_DIGIT_ERROR_CODE = 2
  MISSING_DIGIT_OR_SIGN_ERROR_CODE = 3
  EOF_REACHED_ERROR_CODE = 4

	def initialize args = {}
    @code = get_error_code(args[:dfa])
    @line = args[:line]
    @column = args[:column]
    @guilty_character = args[:guilty_character]
	end

  def error buffer
    message = "ERRO#{@code} - "

    case @code
    when ErrorHelper::UNEXPECTED_CHARACTER_ERROR_CODE
      message += "Caractere '#{@guilty_character}'"
      message += ' inesperado na linguagem'
    when ErrorHelper::MISSING_DIGIT_ERROR_CODE
      message += "Caractere '#{@guilty_character}'"
      message += " inesperado em '#{buffer}' ao invés de dígito"
    when ErrorHelper::MISSING_DIGIT_OR_SIGN_ERROR_CODE
      message += "Caractere '#{@guilty_character}' inesperado"
      message += " em '#{buffer}' ao invés de dígito ou sinal ('+', '-')"
    when ErrorHelper::EOF_REACHED_ERROR_CODE
      message += "Fim de arquivo alcançado antes de terminar o lexema #{buffer}"
    end

    message += ", linha #{@line}, coluna #{@column}"
  end

  def get_error_code dfa
    code = nil
    case dfa.previous_state
    when Dfa::INITIAL_STATE
      code = UNEXPECTED_CHARACTER_ERROR_CODE
    when 's1', 's2', 's5', 's6'
      code = MISSING_DIGIT_ERROR_CODE
    when 's4'
      code = MISSING_DIGIT_OR_SIGN_ERROR_CODE
    when Dfa::EOF_STATE
      code = EOF_REACHED_ERROR_CODE
    end
  end
end
