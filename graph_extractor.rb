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
    lines.select do |line|
      line.strip != ""
    end
  end

  def grab_class_names
    words = @code_lines[0].split(/\W+/)
    words = words.select { |word| word.strip != "" }
    words[1].to_sym
  end
end
