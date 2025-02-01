class String
  def to_py : Crython::PyObject
    ptr = LibPython.unicode_from_string_and_size(self.to_unsafe, self.size)
    Crython::PyObject.new(ptr)
  end
end
