struct Tuple
  def to_py : Crython::PyObject
    tuple = Crython::LibPython.tuple_new(self.size)
    self.each_with_index do |item, index|
      # item.to_py returns a new reference.
      # PyTuple_SetItem steals a reference, so after passing the raw pointer
      # the ownership is transferred to the tuple. We therefore mark the
      # wrapper as not needing decref to avoid double free.
      py_item = item.to_py
      Crython::LibPython.tuple_set_item(tuple, index, py_item.to_unsafe)
      py_item.need_decref = false
    end
    Crython::PyObject.new(tuple, need_decref: true)
  end
end
