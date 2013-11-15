class ClassDefinitionExtractor
  EMPTY_STR = ""
  NEW_SCOPE = "new scope"

  attr_reader :scopes

  def initialize(code)
    @scopes = []
    @code_lines = non_empty_lines(code)
  end

  def extract
    @code_lines.each do |line|
      if line.start_with?("class")
        @scopes.push(NEW_SCOPE)
      elsif line.start_with?("end")
        @scopes.pop
      end
    end
  end

  def non_empty_lines(code)
    lines = code.split(/\n/)
    lines.select { |line| line.strip != EMPTY_STR }.map(&:strip)
  end
end
