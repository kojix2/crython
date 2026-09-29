class String
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.unicode_from_string_and_size(to_unsafe, bytesize)
      Crython::PyObject.from_owned(ptr)
    end
  end

  def self.new(pyobject : Crython::PyObject) : String
    Crython.with_gil do
      bytesize = uninitialized LibC::SSizeT
      ptr = Crython::LibPython.unicode_as_utf8_and_size(pyobject, pointerof(bytesize))
      raise Crython::ValueError.new("Failed to convert Python string to UTF-8") if ptr.null?
      String.new(ptr, bytesize.to_i)
    end
  end
end

struct Char
  def to_py : Crython::PyObject
    Crython.with_gil do
      str = to_s
      ptr = Crython::LibPython.unicode_from_string_and_size(str.to_unsafe, str.bytesize)
      Crython::PyObject.from_owned(ptr)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Char
    Crython.with_gil do
      bytesize = uninitialized LibC::SSizeT
      ptr = Crython::LibPython.unicode_as_utf8_and_size(pyobject, pointerof(bytesize))
      raise Crython::ValueError.new("Failed to convert Python string to UTF-8") if ptr.null?
      String.new(ptr, bytesize.to_i)[0]
    end
  end
end
