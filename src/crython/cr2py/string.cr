class String
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.unicode_from_string(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : String
    Crython.with_gil do
      ptr = Crython::LibPython.unicode_as_utf8(pyobject)
      String.new(ptr)
    end
  end
end

struct Char
  def to_py : Crython::PyObject
    Crython.with_gil do
      str = self.to_s
      ptr = Crython::LibPython.unicode_from_string(str)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Char
    Crython.with_gil do
      ptr = Crython::LibPython.unicode_as_utf8(pyobject)
      String.new(ptr)[0]
    end
  end
end
