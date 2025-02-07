module Crython
  @[Link("python3")]
  lib LibPython
    alias PyObject = Void*
    alias UInt = LibC::UInt
    alias Int = LibC::Int
    alias Double = LibC::Double
    alias ULong = LibC::ULong
    alias Long = LibC::Long
    alias ULongLong = LibC::ULongLong
    alias LongLong = LibC::LongLong
    alias Char = LibC::Char
    alias FILE = Void*

    # Initialization and Finalization
    fun init = Py_Initialize
    fun init_ex = Py_InitializeEx(initsigs : Int)
    fun is_initialized = Py_IsInitialized : Int
    fun finalize = Py_Finalize
    fun finalize_ex = Py_FinalizeEx : Int

    # Python Home
    fun set_python_home = Py_SetPythonHome(home : Char*)
    fun get_python_home = Py_GetPythonHome : Char*

    # Path
    fun sys_set_path = PySys_SetPath(path : Char*)
    fun sys_get_path = PySys_GetPath : Char*

    # Version
    fun get_version = Py_GetVersion : Char*
    fun get_compiler = Py_GetCompiler : Char*
    fun get_build_info = Py_GetBuildInfo : Char*

    # Error Handling
    fun err_clear = PyErr_Clear
    fun err_occurred = PyErr_Occurred : PyObject
    fun err_print = PyErr_Print

    # Run / Eval
    fun run_simple_string = PyRun_SimpleString(str : Char*) : Int
    fun compile_string = Py_CompileString(str : Char*, file : Char*, start : Int) : PyObject
    fun eval_eval_code = PyEval_EvalCode(code : PyObject, globals : PyObject, locals : PyObject) : PyObject

    # Module
    fun import = PyImport_ImportModule(name : Char*) : PyObject

    # Reference Counting Functions
    fun incref = Py_IncRef(o : PyObject)
    fun decref = Py_DecRef(o : PyObject)

    # Object
    fun object_has_attr_string = PyObject_HasAttrString(o : PyObject, attr : Char*) : Int
    fun object_get_attr_string = PyObject_GetAttrString(o : PyObject, attr : Char*) : PyObject
    fun object_set_attr_string = PyObject_SetAttrString(o : PyObject, attr : Char*, val : PyObject) : Int
    fun object_del_attr_string = PyObject_DelAttrString(o : PyObject, attr : Char*) : Int

    # Attribute
    fun object_get_item = PyObject_GetItem(o : PyObject, key : PyObject) : PyObject
    fun object_set_item = PyObject_SetItem(o : PyObject, key : PyObject, val : PyObject) : Int

    # Function
    fun object_is_callable = PyCallable_Check(o : PyObject) : Int
    fun object_call_function = PyObject_CallFunctionObjArgs(callable : PyObject, ...) : PyObject
    fun object_call = PyObject_Call(callable : PyObject, args : PyObject, kwargs : PyObject) : PyObject

    fun object_print = PyObject_Print(o : PyObject, fd : FILE, flags : Int) : Int
    fun object_cmp = PyObject_Cmp(a : PyObject, b : PyObject, res : Int*) : Int

    fun object_str = PyObject_Str(o : PyObject) : PyObject
    fun object_repr = PyObject_Repr(o : PyObject) : PyObject

    fun object_type = PyObject_Type(o : PyObject) : PyObject
    fun object_is_instance = PyObject_IsInstance(o : PyObject, cls : PyObject) : Int
    fun object_is_subclass = PyObject_IsSubclass(o : PyObject, cls : PyObject) : Int

    # Build Value
    fun build_value = Py_BuildValue(format : Char*, ...) : PyObject

    # Parse
    fun arg_parse_tuple = PyArg_ParseTuple(args : PyObject, format : Char*, ...) : Int
    fun arg_parse = PyArg_Parse(args : PyObject, format : Char*, ...) : Int

    # Unicode
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

    # Slice
    fun slice_new = PySlice_New(start : PyObject, stop : PyObject, step : PyObject) : PyObject

    # Bool
    fun bool_check = PyBool_Check(o : PyObject) : Int
    fun bool_from_long = PyBool_FromLong(i : Long) : PyObject

    # Integer
    fun long_check = PyLong_Check(o : PyObject) : Int
    fun long_check_exact = PyLong_CheckExact(o : PyObject) : Int
    fun long_from_long = PyLong_FromLong(v : Long) : PyObject
    fun long_from_unsigned_long = PyLong_FromUnsignedLong(v : ULong) : PyObject
    fun long_from_size_t = PyLong_FromSize_t(v : LibC::SizeT) : PyObject
    fun long_from_long_long = PyLong_FromLongLong(v : LongLong) : PyObject
    fun long_from_unsigned_long_long = PyLong_FromUnsignedLongLong(v : ULongLong) : PyObject
    fun long_from_double = PyLong_FromDouble(v : Double) : PyObject
    fun long_from_string = PyLong_FromString(str : Char*, pend : Char**, base : Int) : PyObject
    fun long_from_void_ptr = PyLong_FromVoidPtr(p : Void*) : PyObject
    fun long_as_long = PyLong_AsLong(i : PyObject) : Long
    fun long_as_int = PyLong_AsInt(i : PyObject) : Int
    fun long_as_long_and_overflow = PyLong_AsLongAndOverflow(i : PyObject, overflow : Int*) : Long
    fun long_as_unsigned_long = PyLong_AsUnsignedLong(i : PyObject) : ULong
    fun long_as_size_t = PyLong_AsSize_t(i : PyObject) : LibC::SizeT
    fun long_as_unsigned_long_long = PyLong_AsUnsignedLongLong(i : PyObject) : ULongLong
    fun long_as_unsigned_long_mask = PyLong_AsUnsignedLongMask(i : PyObject) : ULong
    fun long_as_unsigned_long_long_mask = PyLong_AsUnsignedLongLongMask(i : PyObject) : ULongLong
    fun long_as_double = PyLong_AsDouble(i : PyObject) : Double
    fun long_as_void_ptr = PyLong_AsVoidPtr(i : PyObject) : Void*
    fun long_get_info = PyLong_GetInfo : PyObject

    # Float
    fun float_check = PyFloat_Check(o : PyObject) : Int
    fun float_check_exact = PyFloat_CheckExact(o : PyObject) : Int
    fun float_from_string = PyFloat_FromString(o : PyObject) : PyObject
    fun float_from_double = PyFloat_FromDouble(v : Double) : PyObject
    fun float_as_double = PyFloat_AsDouble(f : PyObject) : Double
    fun float_get_info = PyFloat_GetInfo : PyObject
    fun float_get_max = PyFloat_GetMax : Double
    fun float_get_min = PyFloat_GetMin : Double

    # Complex
    fun complex_from_doubles = PyComplex_FromDoubles(real : Double, imag : Double) : PyObject
    fun complex_real_as_double = PyComplex_RealAsDouble(o : PyObject) : Double
    fun complex_imag_as_double = PyComplex_ImagAsDouble(o : PyObject) : Double
  end
end
