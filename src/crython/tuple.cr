struct Tuple
  def to_py : Crython::PyObject
    tuple = LibPython.tuple_new(self.size)
    self.each_with_index do |item, index|
      LibPython.tuple_set_item(tuple, index, item.to_py)
    end
    Crython::PyObject.new(tuple)
  end
end
