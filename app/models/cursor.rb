class Cursor
  attr_accessor :index, :line, :column

  def initialize
		@index = 0
		@line = 1
		@column = 1
	end

	def update_position current_character
    return if current_character.nil?
    @index += 1
    if character_is_line_break?(current_character)
      @line += 1
      @column = 1
    else
      @column += 1
    end
	end

  private

  def character_is_line_break? character
    character == '\n' ||
    character == '\r'
  end
end
