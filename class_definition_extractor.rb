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
  DO = "do"

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
    tokens = line.split(/\s+/)
    return false if tokens.empty?
    tokens[0] == CLASS
  end

  def grab_class_name(line)
    tokens = line.split(/\s+/)
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
        @current_class = grab_class_name(line)
        class_defs[@current_class] = []
      end
      scopes.push(NEW_SCOPE)
    elsif left_scope?(line)
      scopes.pop
    end
    add_line_to_class_def(line)
  end

  def add_line_to_class_def(line)
    class_defs[@current_class] << line unless scopes.empty? || @current_class.nil?
  end

  def entered_scope?(line)
    tokens = line.split(/\s+/)
    return false if tokens.empty?
    tokens.first == CLASS   ||
    tokens.first == DEF     ||
    tokens.first == UNLESS  ||
    tokens.first == MODULE  ||
    tokens.first == IF      ||
    tokens.first == CASE    ||
    tokens.include?(DO)
  end

  def left_scope?(line)
    line.start_with?(END_WORD)
  end
end
