class LexicalAnalyzer
  attr_accessor :source_code, :cursor, :dfa,
                :current_state, :current_character, :buffer

  def initialize args
    @source_code = args[:source_code]
    @cursor = Cursor.new
    @dfa = Dfa.new
    @current_state = Dfa::INITIAL_STATE
    @current_character = source_code[cursor.index]
    @buffer = ''
  end

  def scan
    print_info
    jump_ignorable_characters

    token = get_next_token

    puts '-' * 99
    puts 'A TOKEN WAS FOUND'
    puts '-' * 99

    treat_error if an_error_was_found?(token)
    reset_current_state
    clean_buffer
    token
  end

  def print_info
    puts '-' * 99
    puts "current state: #{ (current_state.nil? ? 'nil' : current_state) }"
    puts "current character: #{ (current_character.nil? ? 'nil' : current_character) }"
    puts "buffer: #{buffer}"
    puts "cursor index: #{cursor.index}"
    puts "cursor line: #{cursor.line}"
    puts "cursor column: #{cursor.column}"
    puts '-' * 99
  end

  private

  def jump_ignorable_characters
    while current_character_is_ignorable?
      @cursor.update_position(@current_character)
      update_current_character
    end
  end

  def get_next_token
    if eof_has_been_reached?
      process_eof
    elsif current_character_is_a_delimiter?
      process_current_character
    elsif lexeme_might_be_a_literal_or_a_comment?
      process_potential_literal_or_comment
    else
      process_lexeme
    end

    token_by_current_state
  end

  def process_eof
    update_current_state
  end

  def lexeme_might_be_a_literal_or_a_comment?
    current_character_is_double_quotes? ||
    current_character_is_open_braces?
  end

  def current_character_is_double_quotes?
    @current_character == "\""
  end

  def current_character_is_open_braces?
    @current_character == '{'
  end

  def current_character_is_close_braces?
    @current_character == '}'
  end

  def reset_current_state
    @current_state = Dfa::INITIAL_STATE
  end

  def clean_buffer
    @buffer = ''
  end

  def current_character_is_ignorable?
    return true if !@current_character.nil? &&
                   @current_character.match(/[\s\t\n]/)
    false
  end

  def update_current_character
    @current_character = @source_code[@cursor.index]
  end

  def eof_has_been_reached?
    @current_character.nil?
  end

  def update_current_state
    @current_state = next_state
  end

  def token_by_current_state
    token_class = nil

    case @current_state
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

    Token.new(token_class: token_class, lexeme: @buffer)
	end

  def treat_error ; end

  def an_error_was_found? token
    token.token_class == 'ERRO'
  end

  def process_potential_literal_or_comment
    if current_character_is_double_quotes?
      process_potential_literal
    elsif current_character_is_open_braces?
      process_potential_comment
    end
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

    while(!current_character_is_close_braces? &&
          !eof_has_been_reached?)
      process_current_character
    end

    process_lexeme
  end

  def process_lexeme
    while(!lexeme_is_done_being_processed?)
      process_current_character
    end
  end

  def lexeme_is_done_being_processed?
    current_character_is_ignorable? ||
    current_character_is_a_delimiter? ||
    eof_has_been_reached?
  end

  def next_state
    transition_key = dfa.transition_key(@current_character, @current_state)

    if dfa.transition_table[@current_state][transition_key].present?
      dfa.transition_table[@current_state][transition_key]
    else
      Dfa::ERROR_STATE
    end
  end

  def current_character_is_a_delimiter?
    return true if !@current_character.nil? &&
                   @current_character.match(/[,\.]/)
    false
  end

  def process_current_character
    add_current_character_to_buffer
    update_current_state
    @cursor.update_position(@current_character)
    update_current_character
    print_info
  end

  def add_current_character_to_buffer
    @buffer += @current_character
  end
end
