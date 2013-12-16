require_relative "./class_definition_extractor"
require_relative "./dependency_extractor"
require 'graphviz'

class DrawDependencyGraph
  def initialize(code_file)
    @file_without_extension = File.basename(code_file, ".*")
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
    draw_with_graphviz
  end

  private

  def draw_with_graphviz 
    graph = GraphViz.new(:G, type: :digraph)
    @classes_dependencies.each do |klass, dependencies|
      create_nodes_and_edges_for_class_dependencies(
        graph, klass, dependencies)
    end
    graph.output(png: "#{@file_without_extension}.png")
  end

  def create_nodes_and_edges_for_class_dependencies(
    graph, klass, dependencies)
    class_node = graph.add_nodes(klass.to_s)
    dependency_nodes = []
    dependencies.each do |dep| 
      dependency_nodes << graph.add_nodes(dep.to_s) 
    end
    dependency_nodes.each do |dep_node| 
      graph.add_edges(class_node, dep_node)
    end
  end
end

DrawDependencyGraph.new(ARGV[0]).draw
