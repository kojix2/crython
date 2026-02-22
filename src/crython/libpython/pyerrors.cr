module Crython
  # https://github.com/python/cpython/blob/main/Include/pyerrors.h

  @[Link("python3")]
  lib LibPython
    fun err_clear = PyErr_Clear
    fun err_occurred = PyErr_Occurred : PyObject
    fun err_print = PyErr_Print
    fun err_fetch = PyErr_Fetch(exc_type : PyObject*, exc_value : PyObject*, exc_tb : PyObject*)
    fun err_normalize_exception = PyErr_NormalizeException(exc_type : PyObject*, exc_value : PyObject*, exc_tb : PyObject*)
  end
end
