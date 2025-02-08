require "complex"

struct Complex
  def to_py : Crython::PyObject
    # Return a new reference. Clone to prevent Crystal garbage collection.
    ptr = Crython::LibPython.complex_from_doubles(self.real.clone, self.imag.clone)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Complex
    real = Crython::LibPython.complex_real_as_double(pyobject)
    imag = Crython::LibPython.complex_imag_as_double(pyobject)
    Complex.new(real, imag)
  end
end
