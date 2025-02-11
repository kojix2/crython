module Crython
  # https://github.com/python/cpython/blob/main/Include/tupleobject.h

  @[Link("python3")]
  lib LibPython
    fun tuple_new = PyTuple_New(size : Int) : PyObject
    fun tuple_size = PyTuple_Size(t : PyObject) : Int
    fun tuple_get_item = PyTuple_GetItem(t : PyObject, i : Int) : PyObject
    fun tuple_set_item = PyTuple_SetItem(t : PyObject, i : Int, val : PyObject) : Int
  end
end
