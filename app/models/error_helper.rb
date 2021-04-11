class ErrorHelper
  attr_accessor :code, :line, :column, :guilty_character

  EOF_REACHED_BEFORE_LITERAL_ENDED_ERROR_CODE = 1
  EOF_REACHED_BEFORE_COMMENT_ENDED_ERROR_CODE = 2
  MISSING_DIGIT_ERROR_CODE = 3
  MISSING_DIGIT_OR_SIGN_ERROR_CODE = 4
  UNEXPECTED_CHARACTER_ERROR_CODE = 5

	def initialize args = {}
    @code = get_error_code(args[:dfa])
    @line = args[:line]
    @column = args[:column]
    @guilty_character = args[:guilty_character]
	end

  def error buffer
    message = "ERRO#{@code} - "

    case @code
    when EOF_REACHED_BEFORE_LITERAL_ENDED_ERROR_CODE
      message += "Fim de arquivo alcançado antes de terminar o literal #{buffer}"
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
    when 's7'
      code = EOF_REACHED_BEFORE_LITERAL_ENDED_ERROR_CODE
    when 's10'
      code = EOF_REACHED_BEFORE_COMMENT_ENDED_ERROR_CODE
    end

    if code.nil?
      case dfa.previous_state
      when 's1', 's2', 's5', 's6'
        code = MISSING_DIGIT_ERROR_CODE
      when 's4'
        code = MISSING_DIGIT_OR_SIGN_ERROR_CODE
      else
        code = UNEXPECTED_CHARACTER_ERROR_CODE if code.nil?
      end
    end
    code
  end
end
