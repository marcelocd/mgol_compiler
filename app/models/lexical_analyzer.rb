class LexicalAnalyzer
  INITIAL_STATE = 's0'
	ID_STATE = 's9'
  EOF_STATE = 's12'
	ERROR_STATE = 's28'

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
				"D"   => "s3"
			},
			"s3" => {
				"D"   => "s3",
				"e"   => "s4",
				"E"   => "s4"
			},
			"s4" => {
				"+"   => "s5",
				"-"   => "s5",
				"D"   => "s6"
			},
			"s5" => {
				"D"   => "s6"
			},
			"s6" => {
				"D"   => "s6"
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
			"s28" => { }
		}
	end
end
