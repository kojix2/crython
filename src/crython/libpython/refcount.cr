module Crython
  # https://github.com/python/cpython/blob/main/Include/refcount.h

  @[Link("python3")]
  lib LibPython
    fun incref = Py_IncRef(o : PyObject)
    fun decref = Py_DecRef(o : PyObject)
  end
end
