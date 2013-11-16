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

  attr_reader :scopes, :class_defs

  def initialize(code)
    @scopes = []
    @class_defs = {}
    @code_lines = non_empty_lines(code)
  end

  def extract
    @code_lines.each do |line|
      manage_scopes_and_class_defs(line)
    end
  end

  def class_def?(line)
    line.start_with?(CLASS) 
  end

  def grab_class_name(line)
    tokens = line.split(/ /).select { |str| str != "" }
    tokens[1].to_sym
  end

  private

  def non_empty_lines(code)
    lines = code.split(/\n/)
    lines.select { |line| line.strip != EMPTY_STR }.map(&:strip)
  end

  def manage_scopes_and_class_defs(line)
    if entered_scope?(line)
      if class_def?(line)
        class_defs[grab_class_name(line)] = ""
      end
      scopes.push(NEW_SCOPE)
    elsif left_scope?(line)
      scopes.pop
    end
  end

  def entered_scope?(line)
    line.start_with?(CLASS)     || 
      line.start_with?(DEF)     ||
      line.start_with?(UNLESS)  ||
      line.start_with?(MODULE)  || 
      line.start_with?(IF)      ||
      line.start_with?(CASE)
  end

  def left_scope?(line)
    line.start_with?(END_WORD)
  end
end
