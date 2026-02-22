struct Bool
  def to_py : Crython::PyObject
    Crython.with_gil do
      py_bool = self ? Crython::LibPython.bool_from_long(1) : Crython::LibPython.bool_from_long(0)
      Crython::PyObject.new(py_bool, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Bool
    Crython.with_gil do
      Crython::LibPython.object_is_true(pyobject) == 1
    end
  end
end
