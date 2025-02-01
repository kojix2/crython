class Hash(K, V)
  def to_py : Crython::PyObject
    dict = LibPython.dict_new
    self.each do |key, value|
      LibPython.dict_set_item(dict, key.to_py, value.to_py)
    end
    Crython::PyObject.new(dict)
  end
end
