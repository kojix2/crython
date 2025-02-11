module Crython
  # https://github.com/python/cpython/blob/main/Include/dictobject.h

  @[Link("python3")]
  lib LibPython
    fun dict_new = PyDict_New : PyObject
    fun dict_size = PyDict_Size(d : PyObject) : Int
    fun dict_get_item = PyDict_GetItem(d : PyObject, key : PyObject) : PyObject
    fun dict_set_item = PyDict_SetItem(d : PyObject, key : PyObject, val : PyObject) : Int
    fun dict_type = PyDict_Type : PyObject
    fun dict_check = PyDict_Check(p : PyObject) : Int
    fun dict_check_exact = PyDict_CheckExact(p : PyObject) : Int
    fun dict_proxy_new = PyDictProxy_New(mapping : PyObject) : PyObject
    fun dict_clear = PyDict_Clear(p : PyObject)
    fun dict_contains = PyDict_Contains(p : PyObject, key : PyObject) : Int
    fun dict_copy = PyDict_Copy(p : PyObject) : PyObject
    fun dict_set_item_string = PyDict_SetItemString(p : PyObject, key : Char*, val : PyObject) : Int
    fun dict_del_item = PyDict_DelItem(p : PyObject, key : PyObject) : Int
    fun dict_del_item_string = PyDict_DelItemString(p : PyObject, key : Char*) : Int
    fun dict_get_item_ref = PyDict_GetItemRef(p : PyObject, key : PyObject, result : PyObject*) : Int
    fun dict_get_item_with_error = PyDict_GetItemWithError(p : PyObject, key : PyObject) : PyObject
    fun dict_get_item_string = PyDict_GetItemString(p : PyObject, key : Char*) : PyObject
    fun dict_get_item_string_ref = PyDict_GetItemStringRef(p : PyObject, key : Char*, result : PyObject*) : Int
    fun dict_set_default = PyDict_SetDefault(p : PyObject, key : PyObject, defaultobj : PyObject) : PyObject
    fun dict_set_default_ref = PyDict_SetDefaultRef(p : PyObject, key : PyObject, default_value : PyObject, result : PyObject*) : Int
    fun dict_pop = PyDict_Pop(p : PyObject, key : PyObject, result : PyObject*) : Int
    fun dict_pop_string = PyDict_PopString(p : PyObject, key : Char*, result : PyObject*) : Int
    fun dict_items = PyDict_Items(p : PyObject) : PyObject
    fun dict_keys = PyDict_Keys(p : PyObject) : PyObject
    fun dict_values = PyDict_Values(p : PyObject) : PyObject
    fun dict_next = PyDict_Next(p : PyObject, ppos : Py_ssize_t*, pkey : PyObject*, pvalue : PyObject*) : Int
    fun dict_merge = PyDict_Merge(a : PyObject, b : PyObject, override : Int) : Int
    fun dict_update = PyDict_Update(a : PyObject, b : PyObject) : Int
    fun dict_merge_from_seq2 = PyDict_MergeFromSeq2(a : PyObject, seq2 : PyObject, override : Int) : Int
  end
end
