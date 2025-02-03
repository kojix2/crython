class Array(T)
  def to_py : Crython::PyObject
    list = Crython::LibPython.list_new(self.size)
    self.each_with_index do |item, index|
      py_item = item.to_py
      py_item.need_decref = false
      Crython::LibPython.list_set_item(list, index, py_item)
    end
    Crython::PyObject.new(list, need_decref: true)
  end
end
