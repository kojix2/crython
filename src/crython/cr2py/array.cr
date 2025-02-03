class Array(T)
  def to_py : Crython::PyObject
    list = Crython::LibPython.list_new(self.size)
    self.each_with_index do |item, index|
      pyitem = item.to_py
      pyitem.need_decref = true
      Crython::LibPython.list_set_item(list, index, item.to_py)
    end
    Crython::PyObject.new(list)
  end
end
