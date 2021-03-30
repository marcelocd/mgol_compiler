class Cursor
  attr_accessor :index, :line, :column

  def initialize
		@index = 0
		@line = 1
		@column = 1
	end

	def update_position current_character
    index += 1
    if current_character.match(/\n/)
      line += 1
      column = 1
    else
      column += 1
    end
	end
end
