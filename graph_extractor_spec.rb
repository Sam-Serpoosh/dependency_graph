require_relative "./graph_extractor"

describe "Dependenchy Graph Extraction" do
  xit "extracts lines of code in a class scope" do
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
end
