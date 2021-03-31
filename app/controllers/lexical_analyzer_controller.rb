class LexicalAnalyzerController < ActionController::Base
  def index
    source_code = 'Hello, world!'

    @lexical_analyzer = LexicalAnalyzer.new(source_code: source_code)
  end
end
