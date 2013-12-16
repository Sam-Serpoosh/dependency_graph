class ClassNameAndScopesRegister
  attr_reader :class_name, :scopes_count

  def initialize(class_name, scopes_count)
    @class_name = class_name
    @scopes_count = scopes_count
  end
end
