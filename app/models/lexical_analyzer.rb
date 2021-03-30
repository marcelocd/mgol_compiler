class LexicalAnalyzer
  attr_accessor :source_code

  def initialize args
    @source_code = args[:source_code]
    @dfa = Dfa.new
    @cursor = Cursor.new
    @current_state = Dfa::INITIAL_STATE
    @current_character = source_code[cursor.index]
    @buffer = ''
  end

  def scan
    jump_ignorable_characters

    token = get_next_token

    # Implement error tokens treatment!
    reset_current_state
    clean_buffer
    token
  end

  private

  def get_next_token
    if eof_has_been_reached?
      update_current_state
      return token_by_current_state
    end

    process_lexeme
    token_by_current_state
  end

  def process_lexeme
    while (!current_character_is_ignorable? &&
           !current_character_is_a_delimiter? &&
           !eof_has_been_reached?)
      process_current_character
      cursor.update_position(current_character)
      update_current_character
    end
  end

  def jump_ignorable_characters
    while current_character_is_ignorable?
      cursor.update_position(current_character)
      update_current_character
    end
  end

  def current_character_is_ignorable?
    return true if current_character.match(/[\s\t\n]/)
    false
  end

  def current_character_is_a_delimiter?
    return true if current_character.match(/[,\.]/)
    false
  end

  def eof_has_been_reached?
    current_character.nil?
  end

  def process_current_character
    add_current_character_to_buffer
    update_current_state
  end

  def token_by_current_state
    token_class = nil

    case current_state
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

    Token.new(token_class: token_class, lexeme: buffer)
	end

  def add_current_character_to_buffer
    buffer += current_character
  end

  def update_current_state
    current_state = next_state
  end

  def update_current_character
    current_character = source_code[cursor.index]
  end

  def next_state
    transition_key = dfa.transition_key(current_character, current_state)

    if dfa.transition_table[current_state][transition_key].present?
      dfa.transition_table[current_state][transition_key]
    else
      Dfa::ERROR_STATE
    end
  end

  def reset_current_state
    current_state = Dfa::INITIAL_STATE
  end

  def clean_buffer
    buffer = ''
  end
end
