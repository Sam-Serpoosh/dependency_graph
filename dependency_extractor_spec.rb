require_relative "./dependency_extractor"

describe DependencyExtractor do
  it "detects usage of another class" do
    code_lines = ["class Foo", "def foo", "bar = Bar.new", 
                  "bar.some_method", "end"]
    dep_extractor = DependencyExtractor.new(:Foo, code_lines)
    dep_extractor.extract
    dep_extractor.dependencies.count.should == 1
    dep_extractor.dependencies.should include(:Bar)
  end

  it "detects dependencies when multiple collaborators exist" do
    code_lines = ["class Foo", "Bar.some_method", "def foo", 
                  "Baz.new", "baz.func", "end"]
    dep_extractor = DependencyExtractor.new(:Foo, code_lines)
    dep_extractor.extract
    dep_extractor.dependencies.should == [:Bar, :Baz]
  end

  it "filters out constants" do
    code_lines = ["class Bar", "SOME_CONSTANT", "def foo", 
                  "Baz.some_method", "end"]
    dep_extractor = DependencyExtractor.new(:Bar, code_lines)
    dep_extractor.extract
    dep_extractor.dependencies.should == [:Baz]
  end
end
