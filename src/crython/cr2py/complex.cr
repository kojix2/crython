require "complex"

struct Complex
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.complex_from_doubles(self.real, self.imag)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end
