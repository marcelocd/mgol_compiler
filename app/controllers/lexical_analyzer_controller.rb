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
    @source_code ||= params[:source_code] || ''
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
end
