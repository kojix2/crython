module Crython
  # https://github.com/python/cpython/blob/main/Include/listobject.h

  @[Link("python3")]
  lib LibPython
    fun list_new = PyList_New(size : Int) : PyObject
    fun list_size = PyList_Size(list : PyObject) : Int
    fun list_get_item = PyList_GetItem(list : PyObject, i : Int) : PyObject
    fun list_set_item = PyList_SetItem(list : PyObject, i : Int, val : PyObject) : Int
    fun list_insert = PyList_Insert(list : PyObject, index : Py_ssize_t, item : PyObject) : Int
    fun list_append = PyList_Append(list : PyObject, item : PyObject) : Int
    fun list_get_slice = PyList_GetSlice(list : PyObject, low : Py_ssize_t, high : Py_ssize_t) : PyObject
    fun list_set_slice = PyList_SetSlice(list : PyObject, low : Py_ssize_t, high : Py_ssize_t, itemlist : PyObject) : Int
    fun list_sort = PyList_Sort(list : PyObject) : Int
    fun list_reverse = PyList_Reverse(list : PyObject) : Int
    fun list_as_tuple = PyList_AsTuple(list : PyObject) : PyObject
  end
end
