struct Symbol
  # Currently, just convert the symbol to a string
  def to_py : Crython::PyObject
    to_s.to_py
  end

  def self.new(pyobject : Crython::PyObject) : Symbol
    raise "Crystal cannot create a Symbol from a PyObject at runtime"
  end
end
