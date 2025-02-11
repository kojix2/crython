module Crython
  # https://github.com/python/cpython/blob/main/Include/sliceobject.h

  @[Link("python3")]
  lib LibPython
    fun slice_new = PySlice_New(start : PyObject, stop : PyObject, step : PyObject) : PyObject
  end
end
