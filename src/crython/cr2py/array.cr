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

  def self.new(pyobject : Crython::PyObject) : Array(T)
    size = Crython::LibPython.list_size(pyobject)
    Array.new(size) do |index|
      # This may be slow
      py_item = Crython::LibPython.list_get_item(pyobject, index)
      py_obj = Crython::PyObject.new(py_item)
      T.new(py_obj)
    end
  end
end
