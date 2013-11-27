require_relative "./class_definition_extractor"
require_relative "./dependency_extractor"

class DrawDependencyGraph
  def initialize(code_file)
    content = File.read(code_file)
    @class_definition_extractor = ClassDefinitionExtractor.new(content)
    @classes_dependencies = Hash.new { |hash, key| hash[key] = [] }
  end

  def draw
    @class_definition_extractor.extract
    class_defs = @class_definition_extractor.class_defs
    class_defs.each do |klass, code_lines|
      dep_extractor = DependencyExtractor.new(klass, code_lines) 
      dep_extractor.extract
      @classes_dependencies[klass] += dep_extractor.dependencies
    end
    pretty_print
  end

  private

  def pretty_print
    @classes_dependencies.each do |klass, dependencies|
      puts "#{klass} ==> #{dependencies.join(", ")}"
    end
  end
end

DrawDependencyGraph.new(ARGV[0]).draw
