struct Tuple
  def to_py : Crython::PyObject
    tuple = LibPython.tuple_new(self.size)
    self.each_with_index do |item, index|
      py_item = item.to_py
      py_item.need_decref = false
      LibPython.tuple_set_item(tuple, index, item.to_py)
    end
    Crython::PyObject.new(tuple)
  end
end
