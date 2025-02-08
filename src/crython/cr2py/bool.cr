struct Bool
  def to_py : Crython::PyObject
    py_bool = self ? Crython::LibPython.bool_from_long(1) : Crython::LibPython.bool_from_long(0)
    Crython::PyObject.new(py_bool)
  end

  def self.new(pyobject : Crython::PyObject) : Bool
    Crython::LibPython.object_is_true(pyobject) == 1
  end
end
