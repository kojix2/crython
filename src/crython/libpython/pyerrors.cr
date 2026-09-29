module Crython
  # https://github.com/python/cpython/blob/main/Include/pyerrors.h

  lib LibPython
    fun err_clear = PyErr_Clear
    fun err_occurred = PyErr_Occurred : PyObject
    fun err_get_raised_exception = PyErr_GetRaisedException : PyObject
    fun err_print = PyErr_Print
    fun err_fetch = PyErr_Fetch(exc_type : PyObject*, exc_value : PyObject*, exc_tb : PyObject*)
    fun err_normalize_exception = PyErr_NormalizeException(exc_type : PyObject*, exc_value : PyObject*, exc_tb : PyObject*)
  end
end
