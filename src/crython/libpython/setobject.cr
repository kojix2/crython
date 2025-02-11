module Crython
  # https://github.com/python/cpython/blob/main/Include/setobject.h

  @[Link("python3")]
  lib LibPython
    fun set_type = PySet_Type : PyObject
    fun frozenset_type = PyFrozenSet_Type : PyObject
    fun set_new = PySet_New(iterable : PyObject) : PyObject
    fun frozenset_new = PyFrozenSet_New(iterable : PyObject) : PyObject
    fun set_size = PySet_Size(anyset : PyObject) : Py_ssize_t
    fun set_contains = PySet_Contains(anyset : PyObject, key : PyObject) : Int
    fun set_add = PySet_Add(set : PyObject, key : PyObject) : Int
    fun set_discard = PySet_Discard(set : PyObject, key : PyObject) : Int
    fun set_pop = PySet_Pop(set : PyObject) : PyObject
    fun set_clear = PySet_Clear(set : PyObject) : Int
  end
end
