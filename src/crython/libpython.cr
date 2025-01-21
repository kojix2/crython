@[Link("python3")]
lib LibPython
  alias PyObject = Void*
  alias Int = LibC::Int
  alias Long = LibC::Long
  alias Char = LibC::Char
  alias FILE = Void*

  fun init = Py_Initialize
  fun init_ex = Py_InitializeEx(initsigs : Int)
  fun is_initialized = Py_IsInitialized : Int
  fun finalize = Py_Finalize
  fun finalize_ex = Py_FinalizeEx : Int

  fun set_python_home = Py_SetPythonHome(home : Char*)
  fun get_python_home = Py_GetPythonHome : Char*

  fun sys_set_path = PySys_SetPath(path : Char*)
  fun sys_get_path = PySys_GetPath : Char*

  fun get_version = Py_GetVersion : Char*
  fun get_compiler = Py_GetCompiler : Char*
  fun get_build_info = Py_GetBuildInfo : Char*

  fun err_clear = PyErr_Clear
  fun err_occurred = PyErr_Occurred : PyObject
  fun err_print = PyErr_Print

  fun import_module = PyImport_ImportModule(name : Char*) : PyObject

  fun object_has_attr_string = PyObject_HasAttrString(o : PyObject, attr : Char*) : Int
  fun object_get_attr_string = PyObject_GetAttrString(o : PyObject, attr : Char*) : PyObject
  fun object_set_attr_string = PyObject_SetAttrString(o : PyObject, attr : Char*, val : PyObject) : Int
  fun object_del_attr_string = PyObject_DelAttrString(o : PyObject, attr : Char*) : Int

  fun object_call_function = PyObject_CallFunctionObjArgs(callable : PyObject, ...) : PyObject
  fun object_call = PyObject_Call(callable : PyObject, args : PyObject, kwargs : PyObject) : PyObject

  fun object_print = PyObject_Print(o : PyObject, fd : FILE, flags : Int) : Int
  fun object_is_callable = PyCallable_Check(o : PyObject) : Int
  fun object_cmp = PyObject_Cmp(a : PyObject, b : PyObject, res : Int*) : Int

  fun object_string = PyObject_Str(o : PyObject) : PyObject
  fun object_repr = PyObject_Repr(o : PyObject) : PyObject

  fun build_value = Py_BuildValue(format : Char*, ...) : PyObject

  fun unicode_get_length = PyUnicode_GetLength(o : PyObject) : Int
  fun unicode_as_utf8 = PyUnicode_AsUTF8(str : PyObject) : Char*
  fun unicode_from_string_and_size = PyUnicode_FromStringAndSize(str : Char*, size : Int) : PyObject

  # List
  fun list_new = PyList_New(size : Int) : PyObject
  fun list_size = PyList_Size(list : PyObject) : Int
  fun list_get_item = PyList_GetItem(list : PyObject, i : Int) : PyObject
  fun list_set_item = PyList_SetItem(list : PyObject, i : Int, val : PyObject)

  # Tuple
  fun tuple_new = PyTuple_New(size : Int) : PyObject
  fun tuple_size = PyTuple_Size(t : PyObject) : Int
  fun tuple_get_item = PyTuple_GetItem(t : PyObject, i : Int) : PyObject
  fun tuple_set_item = PyTuple_SetItem(t : PyObject, i : Int, val : PyObject) : Int

  # Dict
  fun dict_new = PyDict_New : PyObject
  fun dict_size = PyDict_Size(d : PyObject) : Int
  fun dict_get_item = PyDict_GetItem(d : PyObject, key : PyObject) : PyObject
  fun dict_set_item = PyDict_SetItem(d : PyObject, key : PyObject, val : PyObject) : Int

  fun long_as_long = PyLong_AsLong(i : PyObject) : Long
end
