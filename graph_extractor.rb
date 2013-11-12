class ClassCodeExtractor
  def initialize(code)
    @code_lines = non_empty_lines(code)
    @code_for_classes = {}
  end

  def extract
    class_code = @code_lines.join("\n")
    @code_for_classes[grab_class_names] = class_code
    @code_for_classes
  end

  private

  def non_empty_lines(code)
    lines = code.split(/\n/)
    lines.select { |line| line.strip != "" }
  end

  def grab_class_names
    line = class_definition_line
    words = line.split(/\W+/)
    words = words.select { |word| word.strip != "" }
    words[1].to_sym
  end

  def class_definition_line
    @code_lines.find do |line|
      line.strip.start_with?("class")
    end
  end
end
