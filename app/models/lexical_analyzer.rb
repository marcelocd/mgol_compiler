class LexicalAnalyzer
  attr_accessor :dfa, :symbol_table, :source_code, :cursor, :buffer,
                :current_state, :previous_state, :current_character,
                :error_helper, :errors

  def scan
    jump_ignorable_characters
    token = get_token
    print_token(token)
    add_error_to_errors_list if an_error_token_was_found?(token)
    insert_token_in_symbol_table(token) if token_is_id?(token) &&
                                           !token.in?(@symbol_table)
    @dfa.prepare_for_the_next_scan(@current_character)
    clean_buffer
    return get_token_from_symbol_table(token) if token.in?(@symbol_table)
    token
  end

  private

  def initialize args = {}
    @dfa = Dfa.new
    @symbol_table = symbol_table_initial_configuration
    @source_code = args[:source_code]
    @cursor = Cursor.new
    @buffer = ''
    @current_character = source_code[cursor.index]
    @error_helper = nil
    @errors = Array.new
  end

  def symbol_table_initial_configuration
    reserved_words.map{ |reserved_word| create_token_from_reserved(reserved_word) }
  end

  def create_token_from_reserved reserved_word
    Token.new(token_class: reserved_word,
              lexeme: reserved_word,
              type: 'NULL')
  end

  def insert_token_in_symbol_table token
    @symbol_table << token
  end

  def token_is_id? token
    token.token_class == 'id'
  end

  def jump_ignorable_characters
    while current_character_is_ignorable?
      @cursor.update_position(@current_character) if current_character_is_line_break?
      update_current_character
    end
  end

  def get_token
    if eof_has_been_reached?
      process_eof
    elsif current_character_is_parenthesis? ||
          current_character_is_a_delimiter? ||
          current_character_is_an_arithmetic_operator?
      process_current_character
    elsif lexeme_might_be_a_numeral?
      process_potential_numeral
    elsif lexeme_might_be_a_literal?
      process_potential_literal
    elsif lexeme_might_be_a_comment?
      process_potential_comment
    elsif lexeme_might_be_a_relational_operator?
      process_potential_relational_operator
    else
      process_lexeme
    end

    return create_token_from_reserved(@buffer) if @buffer.in? reserved_words
    token_by_current_state
  end

  def an_error_token_was_found? token
    token.token_class == 'ERRO'
  end

  def an_error_was_found?
    @dfa.current_state == Dfa::ERROR_STATE &&
    @dfa.previous_state != Dfa::ERROR_STATE
  end

  def add_error_to_errors_list
    @errors << @error_helper.error(@buffer)
    print_error
  end

  def print_error
    puts @errors.last
  end

  def clean_buffer
    @buffer = ''
  end

  def get_token_from_symbol_table token
    @symbol_table.each do |tk|
      return tk if tk.lexeme == token.lexeme
    end
  end

  def process_eof
    @dfa.go_to_the_next_state(@current_character)
  end

  def process_current_character
    add_current_character_to_buffer
    @dfa.go_to_the_next_state(@current_character)
    instantiate_error_helper if an_error_was_found?
    @cursor.update_position(@current_character)
    update_current_character
  end

  def instantiate_error_helper
    params = { dfa: dfa,
               line: @cursor.line,
               column: @cursor.column,
               guilty_character: @current_character }

    @error_helper = ErrorHelper.new(params)
  end

  def lexeme_might_be_a_numeral?
    current_character_is_a_digit?
  end

  def process_potential_numeral
    process_current_character while current_character_is_a_digit?

    if current_character_is_a_dot?
      process_current_character
      return if !current_character_is_a_digit?
      process_current_character while current_character_is_a_digit?
    end

    if current_character_is_an_e?
      process_current_character
      process_current_character if current_character_is_a_sign?
      return if !current_character_is_a_digit?
      process_current_character while current_character_is_a_digit?
    end

    process_lexeme
  end

  def lexeme_might_be_a_literal?
    current_character_is_double_quotes?
  end

  def process_potential_literal
    process_current_character

    while(!current_character_is_double_quotes? &&
          !eof_has_been_reached?)
      process_current_character
    end

    process_lexeme
  end

  def process_potential_comment
    process_current_character

    while(!(@current_character == '}') &&
          !eof_has_been_reached?)
      process_current_character
    end

    process_lexeme
  end

  def lexeme_might_be_a_relational_operator?
    current_character_is_a_relational_operator?
  end

  def process_potential_relational_operator
    previous_character = @current_character

    process_current_character
    case previous_character
    when '<'
      process_current_character if @current_character == '=' ||
                                   @current_character == '>' ||
                                   @current_character == '-'
    when '>'
      process_current_character if @current_character == '='
    end
  end

  def process_lexeme
    while(!lexeme_finished_being_processed?)
      process_current_character
    end
  end

  def reserved_words
    ['inicio',
     'varinicio',
     'varfim',
     'escreva',
     'leia',
     'se',
     'entao',
     'fimse',
     'facaate',
     'fimfaca',
     'fim',
     'inteiro',
     'lit',
     'real']
  end

  def token_by_current_state
    token_class = nil

    case @dfa.current_state
    when Dfa::INITIAL_STATE
    when 's1', 's3', 's6'
      token_class = 'Num'
    when 's8'
      token_class = 'Literal'
    when Dfa::ID_STATE
      token_class = 'id'
    when 's11'
      token_class = 'Comentário'
    when Dfa::EOF_STATE
      token_class = 'EOF'
    when 's13', 's14', 's15', 's16', 's17', 's19'
      token_class = 'OPR'
    when 's18'
      token_class = 'RCB'
    when 's20', 's21', 's22', 's23'
      token_class = 'OPM'
    when 's24'
      token_class = 'AB_P'
    when 's25'
      token_class = 'FC_P'
    when 's26'
      token_class = 'PT_V'
    when 's27'
      token_class = 'Vir'
    else
      token_class = 'ERRO'
    end

    Token.new(token_class: token_class,
              lexeme: @buffer,
              type: 'NULL')
	end

  def add_current_character_to_buffer
    @buffer += @current_character
  end

  def lexeme_finished_being_processed?
    eof_has_been_reached? ||
    current_character_is_ignorable? ||
    current_character_is_a_delimiter? ||
    current_character_is_parenthesis? ||
    current_character_is_a_relational_operator? ||
    current_character_is_an_arithmetic_operator?
  end

  def current_character_is_ignorable?
    @current_character == "\s" ||
    @current_character == "\t" ||
    @current_character == "\n" ||
    @current_character == "\r"
  end

  def update_current_character
    @current_character = @source_code[@cursor.index]
  end

  def eof_has_been_reached?
    @current_character.nil?
  end

  def current_character_is_line_break?
    @character == '\n' ||
    @character == '\r'
  end

  def current_character_is_parenthesis?
    @current_character == '(' ||
    @current_character == ')'
  end

  def current_character_is_a_delimiter?
    @current_character == ',' ||
    @current_character == ';'
  end

  def current_character_is_an_arithmetic_operator?
    @current_character == '+' ||
    @current_character == '-' ||
    @current_character == '*' ||
    @current_character == '/'
  end

  def current_character_is_a_digit?
    @current_character.in?(Array.new(10) { |i| i.to_s })
  end

  def lexeme_might_be_a_comment?
    @current_character == '{'
  end

  def current_character_is_a_dot?
    @current_character == '.'
  end

  def current_character_is_a_sign?
    @current_character == '+' ||
    @current_character == '-'
  end

  def current_character_is_an_e?
    @current_character == 'e' ||
    @current_character == 'E'
  end

  def current_character_is_double_quotes?
    @current_character == "\""
  end

  def current_character_is_a_relational_operator?
    @current_character == '>' ||
    @current_character == '<' ||
    @current_character == '='
  end

  def print_token token
    puts "Classe: #{token.token_class}, Lexema: #{token.lexeme}, Tipo: #{token.type}"
  end

  def print_info
    puts '-' * 99
    puts "current state: #{(@dfa.current_state.nil? ? 'nil' : @dfa.current_state)}"
    puts "current character: #{(current_character.nil? ? 'nil' : current_character)}"
    puts "buffer: #{@buffer}"
    puts "cursor index: #{@cursor.index}"
    puts "cursor line: #{@cursor.line}"
    puts "cursor column: #{@cursor.column}"
    puts '-' * 99
  end

  def log message
    puts '-' * 99
    puts message
    puts '-' * 99
  end
end
