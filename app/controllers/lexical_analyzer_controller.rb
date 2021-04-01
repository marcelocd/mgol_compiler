class LexicalAnalyzerController < ActionController::Base
  def index
    source_code = params[:source_code] || ''

    @lexical_analyzer = LexicalAnalyzer.new(source_code: source_code)
  end
end
