class Hash(K, V)
  def to_py : Crython::PyObject
    dict = Crython::LibPython.dict_new
    self.each do |key, value|
      py_key = key.to_py
      py_value = value.to_py
      Crython::LibPython.dict_set_item(dict, py_key, py_value)
      Crython::LibPython.decref(py_key)
      Crython::LibPython.decref(py_value)
    end
    Crython::PyObject.new(dict)
  end
end
