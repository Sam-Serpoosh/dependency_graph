require_relative "./class_definition_extractor"

describe ClassDefinitionExtractor do 
  context "#no_nested_calsses_or_modules" do
    context "#sole_class_in_file" do
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

      it "enters a new scope when encounter method definition" do
        code = %Q{
          class Foo
            def foo
        }
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.scopes.count.should == 2
      end

      it "exits from current scope when encounter 'end' keyword" do
        code = %Q{
          class Foo
            def foo
            end
        }
        extractor = ClassDefinitionExtractor.new(code) 
        extractor.extract
        extractor.scopes.count.should == 1
      end

      it "enters a new scope when enter a block" do
        code = %Q{
          class Foo
            define_method(:hello) do |name|
              puts "Hello -name-"
              # incomplete for scope test purposes
        }
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.scopes.count.should == 2
      end

      it "checks the actual token for scope detection NOT starting chars" do
        code = %Q{
          class Foo
            classification something 
            # this line starts w/ 'class' as well but not a scope entrance
        }
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.scopes.count.should == 1
      end

      it "stores the name of the class when enter its definition" do
        code = %Q{
          class Foo
            def bar
            end
          end
        }
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.class_defs.should have_key("Foo")
      end

      it "stores class definition code lines for a class" do
        code = %Q{
          class Foo
            def foo
              puts "Hello World!"
            end
          end
        }
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        class_def = extractor.class_defs["Foo"]
        contains_all?(class_def, "class Foo", "def foo", 
                      %Q[puts "Hello World!"], "end").should be_true
      end

      def contains_all?(ary, *elements)
        elements.each do |element|
          if !ary.include?(element)
            puts "Missing value '#{element}'"
            return false
          end
        end
        true
      end
    end

    context "#multiple_classes_in_file" do
      it "stores all defined class names in the code" do
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
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.class_defs.should have_key("Foo")
        extractor.class_defs.should have_key("Bar")
      end 

      it "stores class definition code lines for all defined classes" do
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
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.class_defs["Foo"].should include("def foo")
        extractor.class_defs["Foo"].should_not include("def bar")
        extractor.class_defs["Bar"].should include("def bar")
        extractor.class_defs["Bar"].should_not include("def foo")
      end

      it "does NOT store lines between class definitions - if exists" do
        code = %Q{
          class Foo
            def foo
            end
          end

          puts "hello world!"

          class Bar
            def bar
            end
          end
        }
        extractor = ClassDefinitionExtractor.new(code)
        extractor.extract
        extractor.class_defs["Foo"].should_not include("puts")
        extractor.class_defs["Bar"].should_not include("puts")
      end
    end

    context ".class_def?" do
      it "knows when the code line is a class definition" do
        line = "class    Foo"
        extractor = ClassDefinitionExtractor.new("")
        extractor.class_def?(line).should be_true
      end

      it "knows when the code line is NOT a class definition" do
        line = "def bar"
        extractor = ClassDefinitionExtractor.new("")
        extractor.class_def?(line).should be_false
      end

      it "knows when the code line is NOT a class definition - checks by 'class' token" do
        line = "class_def = 'something'"
        extractor = ClassDefinitionExtractor.new("")
        extractor.class_def?(line).should be_false
      end
    end

    context ".grab_class_name" do
      it "grabs the class name out of class definition line" do
        line = "class   Foo"
        extractor = ClassDefinitionExtractor.new(line)
        extractor.grab_class_name(line).should == "Foo"
      end
    end
  end

  context "#nested_class_definitions" do
    it "catches the nested class name correctly" do
      code = %Q{
        module M
          class C
            def foo
            end
          end
        end
      }
      extractor = ClassDefinitionExtractor.new(code)
      extractor.extract
      extractor.class_defs.keys.should include("M::C")
    end

    it "restores to previous class with its code lines when exits from current nested class" do
      code = %Q{
        module A
          puts "Hello from A"
          class B
            puts "Hello from B"
          end

          puts "Bye from A"
      }
      extractor = ClassDefinitionExtractor.new(code)
      extractor.extract
      extractor.class_defs["A"].should include(%Q[puts "Bye from A"])
      extractor.class_defs["A"].should_not include("class B")
      extractor.class_defs["A::B"].should include(%[puts "Hello from B"])
      extractor.class_defs["A::B"].
        should_not include(%Q[puts "Bye from A"])
    end
  end

  context "#class_or_module_with_no_lines_of_code" do
    it "does not include a empty definition class or module" do
      code = %Q{
        module A
          class B
            def foo
            end
          end
        end
      }
      extractor = ClassDefinitionExtractor.new(code)
      extractor.extract
      extractor.class_defs.keys.should == ["A::B"]
    end
  end
end
