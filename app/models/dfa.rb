class Dfa
  INITIAL_STATE = 's0'
	ID_STATE = 's9'
  EOF_STATE = 's12'
	ERROR_STATE = 's28'

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
				"\"" => "s7",
				"L"=> "s9",
				"{"=> "s10",
				"EOF" => EOF_STATE,
				">" => "s13",
				"=" => "s15",
				"<" => "s16",
				"+" => "s20",
				"-" => "s21",
				"*" => "s22",
				"/" => "s23",
				"(" => "s24",
				")" => "s25",
				";" => "s26",
				"," => "s27",
				"ERROR" => "s28"
			},
			"s1" => {
				"D" => "s1",
        "." => "s2",
        "e" => "s4",
				"E" => "s4"
			},
			"s2" => {
        "D" => "s3"
      },
			"s3" => {
				"D" => "s3",
				"e" => "s4",
				"E" => "s4"
			},
			"s4" => {
				"+" => "s5",
				"-" => "s5",
				"D" => "s6"
			},
			"s5" => {
				"D" => "s6"
			},
			"s6" => {
				"D" => "s6"
			},
			"s7" => {
        "NON_DOUBLE_QUOTES" => "s7",
				"\"" => "s8"
			},
			"s8" => { },
			ID_STATE => {
				"D" => ID_STATE,
				"L" => ID_STATE,
				"_" => ID_STATE
			},
			"s10" => {
        "NON_CLOSING_BRACES" => "s10",
				"}" => "s11"
			},
			"s11" => { },
			EOF_STATE => { },
			"s13" => {
				"=" => "s14"
			},
			"s14" => { },
			"s15" => { },
			"s16" => {
				">" => "s17",
				"-" => "s18",
				"=" => "s19"
			},
			"s17" => { },
			"s18" => { },
			"s19" => { },
			"s20" => { },
			"s21" => { },
			"s22" => { },
			"s23" => { },
			"s24" => { },
			"s25" => { },
			"s26" => { },
			"s27" => { },
			ERROR_STATE => { }
    }
	end

  def transition_key character, state
    if character.nil?
      'EOF'
    elsif state == 's7'
      return character if character == "\""
      'NON_DOUBLE_QUOTES'
    elsif state == 's10'
      return character if character == "}"
      'NON_CLOSING_BRACES'
    elsif character.match(/[0-9]/)
      'D'
    elsif character.match(/[a-zA-Z]/)
      return character if state.in?(['s1', 's3']) &&
                          character.in?(['e', 'E'])
      'L'
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

  def is_final_state? state
    non_final_states = [INITIAL_STATE, 's2', 's4', 's5', 's7', 's10', ERROR_STATE]

    return false if state.in? non_final_states
    true
	end
end
