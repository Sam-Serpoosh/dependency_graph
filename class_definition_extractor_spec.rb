require_relative "./class_definition_extractor"

describe ClassDefinitionExtractor do 
  context "#not_nested_definition_and_sole_class_in_file" do
    it "enters a new scope when encounter a class def" do
      code = %Q{
        class Foo
        # no end on purpose
      }
      extractor = ClassDefinitionExtractor.new(code)
      extractor.extract
      extractor.scopes.count.should == 1
    end

    it "exits a scope when encounter end of class def" do
      code = %Q{
        class Foo
        end
      }
      extractor = ClassDefinitionExtractor.new(code)
      extractor.extract
      extractor.scopes.count.should == 0
    end 
  end
end