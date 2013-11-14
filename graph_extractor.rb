class ClassCodeExtractor
  CLASS = "class"

  def initialize(code)
    @code_lines = non_empty_lines(code)
    @code_for_classes = {}
  end

  def extract
    class_names = grab_all_class_names
    class_names.each_with_index do |class_name, index|
      @code_for_classes[class_name] = 
        get_class_definition(class_names, index)
    end
    @code_for_classes
  end

  def get_class_definition(class_names, class_index)
    class_line_index = class_def_line_index(class_names[class_index])
    next_class_line_index = class_def_line_index(
      class_names[class_index + 1])
    @code_lines[class_line_index..next_class_line_index - 1].join("\n")
  end

  private

  def class_def_line_index(class_name)
    return 0 if class_name.nil?
    @code_lines.each do |line|
      if line.include?(CLASS) && line.include?(class_name.to_s)
        return @code_lines.index(line)
      end
    end
    0
  end

  def non_empty_lines(code)
    lines = code.split(/\n/)
    lines.select { |line| line.strip != "" }
  end

  def grab_all_class_names
    lines = class_definition_lines
    extract_class_names(lines)
  end

  def class_definition_lines
    @code_lines.select do |line|
      line.strip.start_with?(CLASS)
    end
  end

  def extract_class_names(class_def_lines)
    class_names = []
    class_def_lines.each do |line|
      words = line.split(/\W+/)
      words = words.select { |word| word.strip != "" }
      class_names << words[1].to_sym
    end
    class_names
  end
end
