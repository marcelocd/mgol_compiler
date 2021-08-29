class Dfa
  INITIAL_STATE = 's0'
  EOF_STATE = 's8'
	ID_STATE = 's9'
	ERROR_STATE = 's25'

  attr_accessor :previous_state, :current_state

  def initialize
    @previous_state = nil
    @current_state = INITIAL_STATE
  end

  def go_to_the_next_state current_character
    @previous_state = @current_state
    @current_state = next_state(current_character)
  end

  def prepare_for_the_next_scan current_character
    @current_state = INITIAL_STATE
    @previous_state = nil
  end

  private

  def transition_table
		{
      INITIAL_STATE => {
				"D"=> "s1",
				"EOF" => EOF_STATE,
				"L"=> ID_STATE,
        "IGNORABLE_CHARACTER" => "s7",
				"'"=> "s10",
				"\"" => "s11",
				"{" => "s14",
				"<" => "s16",
				">" => "s17",
				"=" => "s18",
				"+" => "s19",
				"-" => "s19",
				"*" => "s19",
				"/" => "s19",
				"(" => "s20",
				")" => "s21",
				"," => "s22",
				";" => "s23",
				"ERROR" => ERROR_STATE
			},
			"s1" => {
				"D" => "s1",
        "." => "s2",
        "e" => "s3",
				"E" => "s3"
			},
			"s2" => {
        "D" => "s4"
      },
			"s3" => {
				"D" => "s5",
				"+" => "s6",
				"-" => "s6"
			},
			"s4" => {
				"D" => "s4",
				"e" => "s3",
				"E" => "s3"
			},
			"s5" => {
				"D" => "s5"
			},
			"s6" => {
				"D" => "s5"
			},
			"s7" => {
        "IGNORABLE_CHARACTER" => "s7"
			},
			"s8" => { },
			ID_STATE => {
				"D" => ID_STATE,
				"L" => ID_STATE,
				"_" => ID_STATE
			},
			"s10" => {
        "NON_SINGLE_QUOTE" => "s12"
			},
			"s11" => {
        "NON_DOUBLE_QUOTES" => "s11",
        "\"" => "s13"
      },
			"s12" => {
        "'" => "s13"
      },
			"s13" => { },
			"s14" => {
        "NON_CLOSING_BRACES" => "s14",
        "}" => "s15"
      },
			"s15" => { },
			"s16" => {
				">" => "s18",
				"=" => "s18",
        "-" => "s24"
			},
			"s17" => {
        "=" => "s18"
      },
			"s18" => { },
			"s19" => { },
			"s20" => { },
			"s21" => { },
			"s22" => { },
			"s23" => { },
			"s24" => { },
			ERROR_STATE => { }
    }
	end

  def transition_key character, state
    if character.nil?
      'EOF'
    elsif state == 's10'
      return character if character == "'"
      'NON_SINGLE_QUOTE'
    elsif state == 's11'
      return character if character == "\""
      'NON_DOUBLE_QUOTES'
    elsif state == 's14'
      return character if character == "}"
      'NON_CLOSING_BRACES'
    elsif character.match(/[0-9]/)
      'D'
    elsif character.match(/[a-zA-Z]/)
      return character if state.in?(['s1', 's4']) &&
                          character.in?(['e', 'E'])
      'L'
    elsif character.match(/[\s\t\n\r]/)
      return 'IGNORABLE_CHARACTER'
    else
      character
    end
  end

  def next_state current_character
    transition_key = transition_key(current_character, @current_state)

    if transition_table[@current_state][transition_key].present?
      transition_table[@current_state][transition_key]
    else
      ERROR_STATE
    end
  end
end
