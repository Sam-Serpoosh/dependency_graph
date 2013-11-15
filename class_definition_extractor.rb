class ClassDefinitionExtractor
  EMPTY_STR = ""
  NEW_SCOPE = "new scope"
  CLASS = "class"
  END_WORD = "end"
  DEF = "def"
  UNLESS = "unless"
  CASE = "case"
  MODULE = "module"
  IF = "if"

  attr_reader :scopes

  def initialize(code)
    @scopes = []
    @code_lines = non_empty_lines(code)
  end

  def extract
    @code_lines.each do |line|
      if enter_scope(line)
        @scopes.push(NEW_SCOPE)
      elsif exit_scope(line)
        @scopes.pop
      end
    end
  end

  private

  def non_empty_lines(code)
    lines = code.split(/\n/)
    lines.select { |line| line.strip != EMPTY_STR }.map(&:strip)
  end

  def enter_scope(line)
    line.start_with?(CLASS)     || 
      line.start_with?(DEF)     ||
      line.start_with?(UNLESS)  ||
      line.start_with?(MODULE)  || 
      line.start_with?(IF)      ||
      line.start_with?(CASE)
  end

  def exit_scope(line)
    line.start_with?(END_WORD)
  end
end
