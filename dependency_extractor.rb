class DependencyExtractor
  attr_reader :dependencies

  def initialize(klass, code_lines)
    @dependencies = []
    @code_lines = code_lines
    @klass = klass
  end

  def extract
    @code_lines.each do |line|
      add_dependency_in_line(line)
    end
  end

  private

  def add_dependency_in_line(line)
    tokens = tokenize_line(line)
    possible_class_names = camel_case_tokens(tokens)
    possible_class_names.each do |name|
      name_sym = name.to_sym
      @dependencies << name_sym if name_sym != @klass
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
      ("A".."Z").include?(token[0])
    end
  end
end
