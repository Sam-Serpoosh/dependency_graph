require_relative "./graph_extractor"

describe "Dependenchy Graph Extraction" do
end

describe ClassCodeExtractor do
  context "#sole_class_in_file" do
    it "sets the whole content as single class code" do
      code = %Q{
        require "something"

        class Foo
        end
      }
      code_extractor = ClassCodeExtractor.new(code)
      class_code = code_extractor.extract
      class_code[:Foo].should include("class Foo")
      class_code[:Foo].should include("end")
    end
  end

  context "#more_than_one_class_in_file" do
    it "fetches all classes names" do
      code = %Q{
        class Foo
          # some code here
        end

        class Bar
          # some code here
        end
      }
      code_extractor = ClassCodeExtractor.new(code)
      classes_codes = code_extractor.extract
      classes_codes.should have_key(:Foo)
      classes_codes.should have_key(:Bar)
    end

    it "sets code for all classes accurately - no code btwn class defs" do
      file_content = %Q{
      class Foo
        def hello
          puts "HELLO"
        end
      end

      class Bar
        def hi
          puts "Hi"
        end

        def baz
          num = 10
          puts "baz"
        end
      end
      }
      code_extractor = ClassCodeExtractor.new(file_content)
      classes_codes = code_extractor.extract
      classes_codes.should have_key(:Foo)
      classes_codes[:Foo].should include("def hello")
      classes_codes.should have_key(:Bar)
      classes_codes[:Bar].should include("num = 10")
    end

    it "sets code for all classes - code between their definitions"
  end

  context ".get_class_definition" do
    it "returns all code when there is ONLY one class" do
      code = %Q{
        class Foo
          def foo
          end
        end
      }
      code_extractor = ClassCodeExtractor.new(code)
      class_def = code_extractor.get_class_definition([:Foo], 0)
      class_def.should include("def foo")
      class_def.should include("end")
    end

    it "returns class definition for class specified by its index" do
      code = %Q{
        class Foo
          def foo
          end
        end

        class Bar
          def bar
          end
        end
      }
      code_extractor = ClassCodeExtractor.new(code)
      class_def = code_extractor.get_class_definition([:Foo, :Bar], 0)
      class_def.should include("def foo")
      class_def.should_not include("def bar")
    end
  end
end
