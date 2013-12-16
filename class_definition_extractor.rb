require_relative "./class_name_and_scopes_register"

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
  WHILE = "while"
  DO = "do"

  attr_reader :scopes, :class_defs

  def initialize(code)
    @scopes = []
    @class_defs = {}
    @code_lines = non_empty_lines(code)
    @classes_and_scopes = []
  end

  def extract
    @code_lines.each do |line|
      manage_scopes_and_class_defs(line)
    end
  end

  def class_def?(line)
    tokens = line.split(/\s+/)
    return false if tokens.empty?
    tokens.first == CLASS || tokens.first == MODULE
  end

  def grab_class_name(line)
    tokens = line.split(/\s+/)
    tokens[1]
  end

  private

  def non_empty_lines(code)
    lines = code.split(/\n/)
    lines.select { |line| line.strip != EMPTY_STR }.map(&:strip)
  end

  def manage_scopes_and_class_defs(line)
    if entered_scope?(line)
      if class_def?(line)
        store_existing_current_class_scope
        update_current_class_and_scopes(line)
      end
      scopes.push(NEW_SCOPE)
    elsif left_scope?(line)
      scopes.pop
      @current_class = nil if scopes.empty?
    end
    add_line_to_class_def(line)
  end

  def store_existing_current_class_scope
    if !@current_class.nil?
      @classes_and_scopes << ClassNameAndScopesRegister.
        new(@current_class.clone, scopes.count)
    end
  end

  def update_current_class_and_scopes(line)
    @current_class = current_class_name(line)
    class_defs[@current_class] = []
    scopes.clear
  end

  def current_class_name(line)
    current_class_name =  grab_class_name(line)
    if @classes_and_scopes.empty?
      return current_class_name
    else
      class_names_so_far = @classes_and_scopes.map(&:class_name)
      return "#{class_names_so_far.join("::")}::#{current_class_name}"
    end
  end

  def add_line_to_class_def(line)
    if scopes.empty? || @current_class.nil?
      return if @classes_and_scopes.empty?
      restore_to_previous_scope
    else
      class_defs[@current_class] << line  
    end
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
    tokens.first == WHILE   ||
    tokens.include?(DO)
  end

  def left_scope?(line)
    tokens = line.split(/\s+/)
    tokens.first == END_WORD
  end

  def restore_to_previous_scope
    previous_class = @classes_and_scopes.pop
    @current_class = previous_class.class_name
    previous_class.scopes_count.times { scopes.push(NEW_SCOPE) }
  end
end
