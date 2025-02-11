module Crython
  # https://github.com/python/cpython/blob/main/Include/complexobject.h

  @[Link("python3")]
  lib LibPython
    fun complex_from_doubles = PyComplex_FromDoubles(real : Double, imag : Double) : PyObject
    fun complex_real_as_double = PyComplex_RealAsDouble(o : PyObject) : Double
    fun complex_imag_as_double = PyComplex_ImagAsDouble(o : PyObject) : Double
  end
end
