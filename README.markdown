#Dependency Graph

If you care about the design and quality of the code that you're writing and you wanna have a loosely coupled and highly cohesive design, then *dependency graph* of the class/module under development can give you some useful information and interesting insight! And of course there's that cliche saying: "Picture worth 1000 words!"

Having a tool that will generate the dependency graph of the class you're working on is a pretty useful thing to have. That's why I wrote this **dependency_graph** program which will take a *ruby script* and produce the dependency graph for it using **GraphViz** for drawing the graph itself.

##SYNOPSIS

Imagine the following very simple stupid ruby code is in the foo.rb file:

```
class Foo
	CONSTANT = "SOME VALUE"
	
	def initialize
		bar = Bar.new(some_argument)
	end
	
	def foo
		bar.baz
		AnotherClass.some_method("foo bar")
	end
end
```

You run the following command:

```
ruby lib/draw_dependency_graph.rb foo.rb
```

and you'll get the following dependency grap

![Dependency Graph or Foo Class](http://masihjesus.files.wordpress.com/2013/11/foo1.png)

Of course this is a super-simplified example for explanation purposes here!

## Current Situation and Further Works

Current Supports:

	* One class per file
	* Multiple classes per file
	* Nested class definitions
	
Further Works:

	* Consider 'require' statements (although it's indirectly supported now)
	* Filter out String values which can be mistaken with class/module names
	* consider ';' as an end of line in code (super easy to handle)
	
	
## Few Notes

There's already some packages/software that does this functionality and draw the dependency graph for a ruby scirpt. For instance [GraphViz ruby interface](https://github.com/glejeune/Ruby-Graphviz/) does that now! This was a fun project that I wanted to work on and it is also something very useful while I'm programming.

**Hope you like it!**