class Hash(K, V)
  def to_py : Crython::PyObject
    dict = Crython::LibPython.dict_new
    self.each do |key, value|
      py_key = key.to_py
      py_key.need_decref = false
      py_value = value.to_py
      py_value.need_decref = false
      Crython::LibPython.dict_set_item(dict, py_key, py_value)
      # FIXME: Check if insertion was successful
      Crython::LibPython.decref(py_key)
      Crython::LibPython.decref(py_value)
    end
    Crython::PyObject.new(dict, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Hash(K, V)
    key_ptr = Crython::LibPython::PyObject.null
    value_ptr = Crython::LibPython::PyObject.null
    pos = 0_i64

    hash = Hash(K, V).new
    while Crython::LibPython.dict_next(pyobject, pointerof(pos), pointerof(key_ptr), pointerof(value_ptr)) != 0
      py_key = Crython::PyObject.new(key_ptr)
      py_value = Crython::PyObject.new(value_ptr)
      key = K.new(py_key)
      value = V.new(py_value)
      hash[key] = value
    end
    hash
  end
end
