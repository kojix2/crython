class String
  def to_py : Crython::PyObject
    ptr = LibPython.unicode_from_string_and_size(self.to_unsafe, self.size)
    Crython::PyObject.new(ptr)
  end
end

struct Char
  def to_py : Crython::PyObject
    str = self.to_s
    Crython::PyObject.new(LibPython.unicode_from_string_and_size(str.to_unsafe, str.size))
  end
end
