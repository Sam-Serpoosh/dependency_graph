class DependencyExtractor
  attr_reader :dependencies

  def initialize(klass, code_lines)
    @dependencies = []
    @code_lines = code_lines
    @klass = klass.to_sym
  end

  def extract
    @code_lines.each do |line|
      add_collaborator_to_dependencies(line)
    end
  end

  private

  def add_collaborator_to_dependencies(line)
    tokens = tokenize_line(line)
    possible_class_names = camel_case_tokens(tokens)
    possible_class_names.each do |name|
      name_sym = name.to_sym
      if name_sym != @klass && !@dependencies.include?(name_sym)
        @dependencies << name_sym 
      end
    end
  end

  def tokenize_line(line)
    tokens = line.split(/\s+/).map(&:strip)
    tokens.map do |token|
      token.split(/\./)
    end.flatten
  end

  def camel_case_tokens(tokens)
    tokens.select do |token|
      start_with_capital(token) && not_constant?(token)
    end
  end

  def start_with_capital(token) 
    ("A".."Z").include?(token[0])
  end

  def not_constant?(token)
    token.each_char do |ch|
      return true if !("A".."Z").include?(ch) && 
                     ch != "_" && 
                     !("0".."9").include?(ch)
    end
    false
  end
end
