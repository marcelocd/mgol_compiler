class SyntaticAnalyzer
	attr_accessor :lex, :current_index, :syntactic_table,
								:first_follow_table, :semantic_rules, :errors

	INITIAL_STATE = '0'

	# FUNÇÕES PÚBLICAS ----------------------------
	# CONSTRUTOR ----------------------------------
	def initialize(args)
		@lex                = args[:lex]
		@current_index      = 0
		@ip                 = nil
		@grammar            = initialize_grammar
		@syntactic_table    = initialize_syntactic_table
		@first_follow_table = initialize_first_follow_table
		@semantic_rules     = []
		@errors             = args[:errors]
	end

	# ---------------------------------------------

	def analyse
		stack = [INITIAL_STATE]

		@ip = @lex.scan
		loop do
			s = stack.last
			a = @ip.token_class
      binding.pry
			if(action(s, a) != nil)
				if(action(s, a).match(/s/))
					stack.push(a)
					
					sl = action(s, a).match(/\d+/)[0]

					stack.push(sl)

					#AQUI
					# pilha_auxiliar << ip
					@ip = @lex.scan
				elsif(action(s, a).match(/r/))
					goto_number = action(s, a).match(/\d+/)[0]
					
					alpha = @grammar[goto_number]['left']
					beta = @grammar[goto_number]['right']
					
					beta_length = count_symbols(beta)
					
					for i in 1..(2 * beta_length)
						stack.pop
					end

					sl = stack.last

					stack.push(alpha)
					stack.push("#{goto(sl, alpha)}")

					# AQUI, SEU BURRO
					# validation = []

					# for i in 0..(beta_length)
					# 	aux = pilha_auxiliar.pop
					# 	validation << aux
					# end

					# non_terminal = rodar_semantico
					# (sempre retorna o alpha)
					# para o semantico, passamos o indice da regra (obtido na tabela),
					# o alfa, o validation, e se houve erro ou nao.
					# Se houver erro,

					# ---------------------------
					
					# @semantic_rules << "#{alpha} => #{beta}"
					# puts @semantic_rules.last
					# return if @ip.token_class == 'EOF'
				elsif(action(s, a) == 'acc')
					break
				else
					treat_error()
				end
			else
				if(a == 'EOF')
					@ip = @lex.scan
					next
				end

				if(@ip.nil?)
				# if((@ip = @lex.get_scan).nil?)
					puts @ip
					return 
				end

				treat_error()
			end
		end
	end

	def initialize_grammar
		return {
			'0' => {
				'left'  => 'P1',
				'right' => 'P'
			},
			'1' => {
				'left'  => 'P',
				'right' => 'inicio V A'
			},
			'2' => {
				'left'  => 'V',
				'right' => 'varinicio LV'
			},
			'3' => {
				'left'  => 'LV',
				'right' => 'D LV'
			},
			'4' => {
				'left'  => 'LV',
				'right' => 'varfim PT_V'
			},
			'5' => {
				'left'  => 'D',
				'right' => 'TIPO L PT_V'
			},
			'6' => {
				'left'  => 'L',
				'right' => 'id VIR L'
			},
			'7' => {
				'left'  => 'L',
				'right' => 'id'
			},
			'8' => {
				'left'  => 'TIPO',
				'right' => 'inteiro'
			},
			'9' => {
				'left'  => 'TIPO',
				'right' => 'real'
			},
			'10' => {
				'left'  => 'TIPO',
				'right' => 'literal'
			},
			'11' => {
				'left'  => 'A',
				'right' => 'ES A'
			},
			'12' => {
				'left'  => 'ES',
				'right' => 'leia id PT_V'
			},
			'13' => {
				'left'  => 'ES',
				'right' => 'escreva ARG PT_V'
			},
			'14' => {
				'left'  => 'ARG',
				'right' => 'lit'
			},
			'15' => {
				'left'  => 'ARG',
				'right' => 'num'
			},
			'16' => {
				'left'  => 'ARG',
				'right' => 'id'
			},
			'17' => {
				'left'  => 'A',
				'right' => 'CMD A'
			},
			'18' => {
				'left'  => 'CMD',
				'right' => 'id RCB LD PT_V'
			},
			'19' => {
				'left'  => 'LD',
				'right' => 'OPRD OPM OPRD'
			},
			'20' => {
				'left'  => 'LD',
				'right' => 'OPRD'
			},
			'21' => {
				'left'  => 'OPRD',
				'right' => 'id'
			},
			'22' => {
				'left'  => 'OPRD',
				'right' => 'num'
			},
			'23' => {
				'left'  => 'A',
				'right' => 'COND A'
			},
			'24' => {
				'left'  => 'COND',
				'right' => 'CAB CP'
			},
			'25' => {
				'left'  => 'CAB',
				'right' => 'se AB_P EXP_R FC_P entao'
			},
			'26' => {
				'left'  => 'EXP_R',
				'right' => 'OPRD OPR OPRD'
			},
			'27' => {
				'left'  => 'CP',
				'right' => 'ES CP'
			},
			'28' => {
				'left'  => 'CP',
				'right' => 'CMD CP'
			},
			'29' => {
				'left'  => 'CP',
				'right' => 'COND CP'
			},
            '30' => {
				'left'  => 'CP',
				'right' => 'fimse'
			},
            '31' => {
				'left'  => 'A',
				'right' => 'R A'
			},
            '32' => {
				'left'  => 'R',
				'right' => 'repita AB_P EXP_R FC_P CP_R'
			},
            '33' => {
				'left'  => 'CP_R',
				'right' => 'ES CP_R'
			}, 
            '34' => {
				'left'  => 'CP_R',
				'right' => 'CMD CP_R'
			},
            '35' => {
				'left'  => 'CP_R',
				'right' => 'COND CP_R'
			},
            '36' => {
				'left'  => 'CP_R',
				'right' => 'fimrepita'
			},
            '37' => {
				'left'  => 'A',
				'right' => 'fim'
			}
		}
	end

	def initialize_syntactic_table
		return {
      "0" => {
        "inicio" => "s2"
      },
      "1" => {
        "$" => "acc"
      },
      "2" => {
        "varinicio" => "s15"
      },
      "3" => {
        "fim" => "s9",
        "leia" => "s24",
        "escreva" => "s11",
        "id" => "s12",
        "repita" => "s66",
        "se" => "s14"
      },
      "4" => {
        "$" => "r1"		
      },
      "5" => {
        "fim" => "s9",
        "leia" => "s24",
        "escreva" => "s11",
        "id" => "s12",
        "repita" => "s66",
        "se" => "s14"
      },
      "6" => {
        "fim" => "s9",
        "leia" => "s24",
        "escreva" => "s11",
        "id" => "s12",
        "repita" => "s66",
        "se" => "s14"
      },
      "7" => {
        "fim" => "s9",
        "leia" => "s24",
        "escreva" => "s11",
        "id" => "s12",
        "repita" => "s66",
        "se" => "s14"
      },
      "8" => {
        "fim" => "s9",
        "leia" => "s24",
        "escreva" => "s11",
        "id" => "s12",
        "repita" => "s66",
        "se" => "s14"
      },
      "9" => {
        "$" => "r37"
      },
      "10" => {
        "id" => "s27"
      },
      "11" => {
        "lit" => "s30",
        "num" => "s31",
        "id" => "s32"
      },
      "12" => {
        "rcb" => "s34"
      },
      "13" => {
        "fimse" => "s39"
      },
      "14" => {
        "AB_P" => "s40"
      },
      "15" => {
        "varfim" => "s17",
        "inteiro" => "s20",
        "real" => "s21",
        "literal" => "s22"
      },
      "16" => {
        "$" => "r2"
      },
      "17" => {
        "PT_V" => "s41"			
      },
      "18" => {
        "varfim" => "s17"
      },
      "19" => {
        "id" => "s43"
      },
      "20" => {
        "id" => "r8"
      },
      "21" => {
        "id" => "r9"
      },
      "22" => {
        "id" => "r10"
      },
      "23" => {
        "$" => "r11"
      },
      "24" => {
        "$" => "r17"
      },
      "25" => {
        "$" => "r23"
      },
      "26" => {
        "$" => "r31"
      },
      "27" => {
        "PT_V" => "s28"
      },
      "28" => {
        "leia" => "r12",
        "escreva" => "r12",	
        "id" => "r12",	
        "se" => "r12",	
        "fim" => "r12",
        "repita" => "r12",
        "fimse" => "r12",
        "fimrepita" => "r12"
      },
      "29" => {
        "PT_V" => "s33"
      },
      "30" => {
        "PT_V" => "r14"
      },
      "31" => {
        "PT_V" => "r15"
      },
      "32" => {
        "PT_V" => "r16"
      },
      "33" => {
        "leia" => "r13",
        "escreva" => "r13",	
        "id" => "r13",	
        "se" => "r13",	
        "fim" => "r13",
        "repita" => "r13",
        "fimse" => "r13",
        "fimrepita" => "r13"
      },
      "34" => {
        "id" => "s46",
        "num" => "s47"
      },
      "35" => {
        "leia" => "r24",
        "escreva" => "r24",	
        "id" => "r24",	
        "se" => "r24",	
        "fim" => "r24",
        "repita" => "r24",
        "fimse" => "r24"
      },
      "36" => {
        "fimse" => "s48"
      },
      "37" => {
        "fimse" => "s48"
      },
      "38" => {
        "fimse" => "s48"
      },
      "39" => {
        "leia" => "r24",
        "escreva" => "r24",	
        "id" => "r24",	
        "se" => "r24",	
        "fim" => "r24",
        "repita" => "r24",
        "fimse" => "r24"
      },
      "40" => {
        "id" => "s46",
        "num" => "s47"
      },
      "41" => {
        "leia" => "r4",
        "escreva" => "r4",	
        "id" => "r4",	
        "se" => "r4",	
        "fim" => "r4",
        "repita" => "r4"
      },
      "42" => {
        "PT_V" => "s55"
      },
      "43" => {
        "VIR" => "s56",
        "PT_V" => "r7"
      },
      "44" => {
        "PT_V" => "s59"
      },
      "45" => {
        "OPM" => "s60"		
      },
      "46" => {
        "OPM" => "r21",
        "PT_V" => "r21",
        "OPR" => "r21",
        "FC_P" => "r21"
      },
      "47" => {
        "OPM" => "r22",
        "PT_V" => "r22",
        "OPR" => "r22",
        "FC_P" => "r22"
      },
      "48" => {
        "leia" => "r30",
        "escreva" => "r30",	
        "id" => "r30",	
        "se" => "r30",	
        "fim" => "r30",
        "repita" => "r30",
        "fimse" => "r30",
        "fimrepita" => "r30"
      },
      "49" => {
        "leia" => "r27",
        "escreva" => "r27",	
        "id" => "r27",	
        "se" => "r27",	
        "fim" => "r27",
        "repita" => "r27",
        "fimse" => "r27",
        "fimrepita" => "r27"
      },
      "50" => {
        "leia" => "r28",
        "escreva" => "r28",	
        "id" => "r28",	
        "se" => "r28",	
        "fim" => "r28",
        "repita" => "r28",
        "fimse" => "r28",
        "fimrepita" => "r28"
      },
      "51" => {
        "leia" => "r29",
        "escreva" => "r29",	
        "id" => "r29",	
        "se" => "r29",	
        "fim" => "r29",
        "repita" => "r29",
        "fimse" => "r29",
        "fimrepita" => "r29"
      },
      "52" => {
        "FC_P" => "s61"
      },	
      "53" => {
        "OPR" => "s62"
      },
      "54" => {
        "leia" => "r34",
        "escreva" => "r34",	
        "id" => "r34",	
        "se" => "r34",	
        "fim" => "r34",
        "repita" => "r34"
      },
      "55" => {
        "leia" => "r5",
        "escreva" => "r5",	
        "id" => "r5",	
        "se" => "r5",
        "repita" => "r5",	
        "fim" => "r5"
      },
      "56" => {
        "id" => "s58"
      },
      "57" => {
        "inteiro" => "r6",	
        "real" => "r6",
        "literal" => "r6"
      },
      "58" => {
        "$" => "r7"
      },
      "59" => {
        "leia" => "r18",
        "escreva" => "r18",	
        "id" => "r18",	
        "se" => "r18",	
        "fim" => "r18",
        "repita" => "r18",
        "fimse" => "r18",
        "fimrepita" => "r18"
      },
      "60" => {
        "id" => "s46",
        "num" => "s47"
      },
      "61" => {
        "entao" => "s64"
      },
      "62" => {
        "id" => "s46",
        "num" => "s47"
      },
      "63" => {
        "PT_V" => "r19"
      },
      "64" => {
        "leia" => "r25",
        "escreva" => "r25",	
        "id" => "r25",	
        "se" => "r25",	
        "fimse" => "r25"
      },
      "65" => {
        "FC_P" => "r26"
      },
      "66" => {
        "AB_P" => "s67"
      },
      "67" => {
        "id" => "s46",
        "num" => "s47"
      },
      "68" => {
        "FC_P" => "s69"
      },	
      "69" => {
        "fimrepita" => "s74",
        "escreva" => "s11",
        "id" => "s12",
        "leia" => "s24",
        "se" => "s14"
      },
      "70" => {
        "leia" => "r32",
        "escreva" => "32",	
        "id" => "r32",	
        "se" => "r32",
        "repita" => "r32",	
        "fim" => "r32"
      },
      "71" => {
        "fimrepita" => "s74",
        "escreva" => "s11",
        "id" => "s12",
        "leia" => "s24",
        "se" => "s14"
      },
      "72" => {
        "fimrepita" => "s74",
        "escreva" => "s11",
        "id" => "s12",
        "leia" => "s24",
        "se" => "s14"
      },
      "73" => {
        "fimrepita" => "s74",
        "escreva" => "s11",
        "id" => "s12",
        "leia" => "s24",
        "se" => "s14"
      },
      "74" => {
        "leia" => "r36",
        "escreva" => "r36",	
        "id" => "r36",	
        "se" => "r36",
        "repita" => "r36",	
        "fim" => "r36"
      },
      "75" => {
        "leia" => "r33",
        "escreva" => "r33",	
        "id" => "r33",	
        "se" => "r33",	
        "fim" => "r33",
        "repita" => "r33"
      }
		}
	end

	def initialize_first_follow_table
	  return {
			'Pl' => {
				'first' => ['inicio'],
				'follow' => ['$']
			},
			'P' => {
				'first' => ['inicio'],
				'follow' => ['$']
			},
			'V' => {
				'first' => ['varinicio'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se','repita']
			},
			'LV' => {
				'first' => ['varfim', 'inteiro','real','literal'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se','repita']
			},
			'D' => {
				'first' => ['inteiro','real','literal'],
				'follow' => ['varfim', 'inteiro', 'real','literal']
			},
			'TIPO' => {
				'first' => ['inteiro', 'real', 'literal'],
				'follow' => ['id']
			},
			'A' => {
				'first' => ['fim', 'leia', 'escreva', 'id', 'se','repita'],
				'follow' => ['$']
			},
      'L' => {
        'first' => ['id'],
        'follow' => ['PT_V']
      },
			'ES' => {
				'first' => ['leia', 'escreva'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse','repita']
			},
			'ARG' => {
				'first' => ['lit', 'num', 'id'],
				'follow' => ['PT_V']
			},
			'CMD' => {
				'first' => ['id'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse','repita']
			},
			'LD' => {
				'first' => ['id', 'num'],
				'follow' => ['PT_V']
			},
			'OPRD' => {
				'first' => ['id', 'num'],
				'follow' => ['OPM', 'PT_V']
			},
			'COND' => {
				'first' => ['se'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse', 'repita']
			},
			'CAB' => {
				'first' => ['se'],
				'follow' => ['leia', 'escreva', 'id', 'fimse', 'se']
			},
			'EXP_R' => {
				'first' => ['id', 'num'],
				'follow' => ['FC_P']
			},
			'CP' => {
				'first' => ['leia', 'escreva', 'id', 'fimse', 'se'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'fimse', 'repita']
			},
      'R' => {
				'first' => ['repita'],
				'follow' => ['fim', 'leia', 'escreva', 'id', 'se', 'repita']
			},
      'CP_R' => {
				'first' => ['leia', 'escreva', 'id', 'fimrepita', 'se'],
				'follow' => []
			}
		}
	end

	# FUNÇÕES DE AUXÍLIO --------------------------
	def action s, a
		return @syntactic_table[s][a]
	end

	def goto s, a
		return @syntactic_table[s][a]
	end

	def count_symbols string
		return string.strip.split(' ').count
	end

	# FUNÇÕES DE ERRO -----------------------------
	def treat_error
		if(@ip.lexeme != '')
			error = "Syntactic Error (line #{@lex.cursor.line}, column #{@lex.cursor.column}): unexpected '#{@ip.lexeme}'."
			
			@errors << error
		end

		while @ip.token_class != 'PT_V' do
			@ip = @lex.scan
		end

		@ip = @lex.scan
	end

	def print_errors
		errors_length = @errors.length()

		if(errors_length > 0)
			for i in 0..(errors_length - 1)
				puts @errors[i]
			end
		end
	end

	# ---------------------------------------------
	# ---------------------------------------------
end