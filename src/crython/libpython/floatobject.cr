module Crython
  # https://github.com/python/cpython/blob/main/Include/floatobject.h

  @[Link("python3")]
  lib LibPython
    fun float_check = PyFloat_Check(o : PyObject) : Int
    fun float_check_exact = PyFloat_CheckExact(o : PyObject) : Int
    fun float_from_string = PyFloat_FromString(o : PyObject) : PyObject
    fun float_from_double = PyFloat_FromDouble(v : Double) : PyObject
    fun float_as_double = PyFloat_AsDouble(f : PyObject) : Double
    fun float_get_info = PyFloat_GetInfo : PyObject
    fun float_get_max = PyFloat_GetMax : Double
    fun float_get_min = PyFloat_GetMin : Double
  end
end
