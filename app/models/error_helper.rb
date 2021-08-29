class ErrorHelper
  attr_accessor :code, :line, :column, :guilty_character

  EOF_REACHED_BEFORE_LITERAL_ENDED_ERROR_CODE = 1
  EOF_REACHED_BEFORE_LITERAL_ENDED_OR_LENGTH_DIFFERENT_FROM_ONE_ERROR_CODE = 2
  EOF_REACHED_BEFORE_COMMENT_ENDED_ERROR_CODE = 3
  MISSING_DIGIT_ERROR_CODE = 4
  MISSING_DIGIT_OR_SIGN_ERROR_CODE = 5
  UNEXPECTED_CHARACTER_ERROR_CODE = 6

	def initialize args = {}
    @code = get_error_code(args[:dfa])
    @line = args[:line]
    @column = args[:column]
    @guilty_character = args[:guilty_character]
	end

  def error buffer
    message = "ERRO #{@code} - "

    case @code
    when EOF_REACHED_BEFORE_LITERAL_ENDED_ERROR_CODE
      message += "Fim de arquivo alcançado antes de terminar o literal #{buffer}"
    when EOF_REACHED_BEFORE_LITERAL_ENDED_OR_LENGTH_DIFFERENT_FROM_ONE_ERROR_CODE
      message += "Fim de arquivo alcançado antes de terminar o literal"
      message += " ou literal com tamanho diferente de 1: #{buffer}"
    when EOF_REACHED_BEFORE_COMMENT_ENDED_ERROR_CODE
      message += "Fim de arquivo alcançado antes de terminar o comentário '#{buffer}'"
    when MISSING_DIGIT_ERROR_CODE
      message += "Caractere '#{@guilty_character}'"
      message += " inesperado em '#{buffer}' ao invés de dígito"
    when MISSING_DIGIT_OR_SIGN_ERROR_CODE
      message += "Caractere '#{@guilty_character}' inesperado"
      message += " em '#{buffer}' ao invés de dígito ou sinal ('+', '-')"
    when UNEXPECTED_CHARACTER_ERROR_CODE
      message += "Caractere '#{@guilty_character}'"
      message += ' inesperado na linguagem'
    end

    message += ", linha #{@line}, coluna #{@column}"
  end

  def get_error_code dfa
    code = nil
    case dfa.current_state
    when 's10', 's12'
      code = EOF_REACHED_BEFORE_LITERAL_ENDED_OR_LENGTH_DIFFERENT_FROM_ONE_ERROR_CODE
    when 's11'
      code = EOF_REACHED_BEFORE_LITERAL_ENDED_ERROR_CODE
    when 's14'
      code = EOF_REACHED_BEFORE_COMMENT_ENDED_ERROR_CODE
    end

    return code if code.present?

    case dfa.previous_state
    when 's2', 's6'
      code = MISSING_DIGIT_ERROR_CODE
    when 's3'
      code = MISSING_DIGIT_OR_SIGN_ERROR_CODE
    else
      code = UNEXPECTED_CHARACTER_ERROR_CODE
    end
    
    code
  end
end
