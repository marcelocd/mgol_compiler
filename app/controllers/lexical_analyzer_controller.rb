class LexicalAnalyzerController < ActionController::Base
  def index
    source_code
    lexical_analyzer
    tokens
    lexical_analyzer.errors.each do |error|
      flash[:errors] = error
    end
  end

  private

  def source_code
    # OPTION 1 -------------
    file = File.open(source_code_path)
		@source_code = file.read
		file.close
    @source_code
    
    # OPTION 2 -------------
    # @source_code ||= remove_double_line_breaks(params[:source_code]) || ''
  end

  def source_code_path
    Rails.root.join('mgol_example_code.txt').to_s
  end

  def lexical_analyzer
    @lexical_analyzer ||= LexicalAnalyzer.new(source_code: source_code)
  end

  def tokens
    return @tokens = [] if source_code.blank?

    @tokens = Array.new
    loop do
      @tokens << lexical_analyzer.scan
      return @tokens if eof_has_been_reached?
    end
  end

  def eof_has_been_reached?
    @tokens.last.token_class == 'EOF'
  end

  def remove_double_line_breaks string
    string.gsub(/\r/, '') if string
  end
end
