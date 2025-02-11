module Crython
  # https://github.com/python/cpython/blob/main/Include/modsupport.h

  @[Link("python3")]
  lib LibPython
    fun build_value = Py_BuildValue(format : Char*, ...) : PyObject
    fun arg_parse_tuple = PyArg_ParseTuple(args : PyObject, format : Char*, ...) : Int
    fun arg_parse = PyArg_Parse(args : PyObject, format : Char*, ...) : Int
  end
end
