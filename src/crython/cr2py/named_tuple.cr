struct NamedTuple
  def to_py : Crython::PyObject
    dict = Crython::LibPython.dict_new
    self.each do |key, value|
      py_key = key.to_py
      py_key.need_decref = false
      py_value = value.to_py
      py_value.need_decref = false
      Crython::LibPython.dict_set_item(dict, py_key, py_value)
      Crython::LibPython.decref(py_key)
      Crython::LibPython.decref(py_value)
    end
    Crython::PyObject.new(dict, need_decref: true)
  end
end
