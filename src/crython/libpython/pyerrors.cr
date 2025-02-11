module Crython
  # https://github.com/python/cpython/blob/main/Include/pyerrors.h

  @[Link("python3")]
  lib LibPython
    fun err_clear = PyErr_Clear
    fun err_occurred = PyErr_Occurred : PyObject
    fun err_print = PyErr_Print
  end
end
