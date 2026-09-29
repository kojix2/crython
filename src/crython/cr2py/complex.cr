require "complex"

struct Complex
  def to_py : Crython::PyObject
    Crython.with_gil do
      # Return a new reference. Clone to prevent Crystal garbage collection.
      ptr = Crython::LibPython.complex_from_doubles(real.clone, imag.clone)
      Crython::PyObject.from_owned(ptr)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Complex
    Crython.with_gil do
      real = Crython::LibPython.complex_real_as_double(pyobject)
      imag = Crython::LibPython.complex_imag_as_double(pyobject)
      Complex.new(real, imag)
    end
  end
end
