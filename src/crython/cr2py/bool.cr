struct Bool
  def to_py : Crython::PyObject
    py_bool = self ? LibPython.bool_from_long(1) : LibPython.bool_from_long(0)
    Crython::PyObject.new(py_bool, need_decref: true)
  end
end
