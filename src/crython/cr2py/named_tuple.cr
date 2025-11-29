struct NamedTuple
  def to_py : Crython::PyObject
    dict = Crython::LibPython.dict_new
    self.each do |key, value|
      # key.to_py / value.to_py return new references.
      # PyDict_SetItem does not steal references; it increments the
      # reference counts of key and value internally. We must decref the
      # temporary references we own after the call.
      py_key = key.to_py
      py_value = value.to_py
      Crython::LibPython.dict_set_item(dict, py_key.to_unsafe, py_value.to_unsafe)
      Crython::LibPython.decref(py_key.to_unsafe)
      Crython::LibPython.decref(py_value.to_unsafe)
      py_key.need_decref = false
      py_value.need_decref = false
    end
    Crython::PyObject.new(dict, need_decref: true)
  end
end
