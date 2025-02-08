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
    fun unicode_is_identifier = PyUnicode_IsIdentifier(str : PyObject) : Int
    fun unicode_from_string_and_size = PyUnicode_FromStringAndSize(str : Char*, size : LibC::SizeT) : PyObject
    fun unicode_from_string = PyUnicode_FromString(str : Char*) : PyObject
    fun unicode_from_format = PyUnicode_FromFormat(format : Char*, ...) : PyObject
    fun unicode_from_format_v = PyUnicode_FromFormatV(format : Char*, ...) : PyObject
    fun unicode_from_object = PyUnicode_FromObject(o : PyObject) : PyObject
    fun unicode_from_encoded_object = PyUnicode_FromEncodedObject(o : PyObject, encoding : Char*, errors : Char*) : PyObject
    fun unicode_get_length = PyUnicode_GetLength(o : PyObject) : Int
    fun unicode_as_utf8 = PyUnicode_AsUTF8(str : PyObject) : Char*

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
    fun long_check = PyLong_Check(obj : PyObject) : Int
    fun long_check_exact = PyLong_CheckExact(obj : PyObject) : Int
    fun long_from_long = PyLong_FromLong(value : Long) : PyObject
    fun long_from_unsigned_long = PyLong_FromUnsignedLong(value : ULong) : PyObject
    fun long_from_size_t = PyLong_FromSize_t(value : LibC::SizeT) : PyObject
    fun long_from_ssize_t = PyLong_FromSsize_t(value : LibC::SSizeT) : PyObject
    fun long_from_long_long = PyLong_FromLongLong(value : LongLong) : PyObject
    fun long_from_unsigned_long_long = PyLong_FromUnsignedLongLong(value : ULongLong) : PyObject
    fun long_from_double = PyLong_FromDouble(value : Double) : PyObject
    fun long_from_string = PyLong_FromString(str : Char*, pend : Char**, base : Int) : PyObject
    fun long_from_unicode_object = PyLong_FromUnicodeObject(unicode : PyObject, base : Int) : PyObject
    fun long_from_void_ptr = PyLong_FromVoidPtr(ptr : Void*) : PyObject
    fun long_as_long = PyLong_AsLong(obj : PyObject) : Long
    fun long_as_int = PyLong_AsInt(obj : PyObject) : Int
    fun long_as_long_and_overflow = PyLong_AsLongAndOverflow(obj : PyObject, overflow : Int*) : Long
    fun long_as_ssize_t = PyLong_AsSsize_t(obj : PyObject) : LibC::SSizeT
    fun long_as_unsigned_long = PyLong_AsUnsignedLong(obj : PyObject) : ULong
    fun long_as_size_t = PyLong_AsSize_t(obj : PyObject) : LibC::SizeT
    fun long_as_long_long = PyLong_AsLongLong(obj : PyObject) : LongLong
    fun long_as_long_long_and_overflow = PyLong_AsLongLongAndOverflow(obj : PyObject, overflow : Int*) : LongLong
    fun long_as_unsigned_long_long = PyLong_AsUnsignedLongLong(obj : PyObject) : ULongLong
    fun long_as_unsigned_long_mask = PyLong_AsUnsignedLongMask(obj : PyObject) : ULong
    fun long_as_unsigned_long_long_mask = PyLong_AsUnsignedLongLongMask(obj : PyObject) : ULongLong
    fun long_as_double = PyLong_AsDouble(obj : PyObject) : Double
    fun long_as_void_ptr = PyLong_AsVoidPtr(obj : PyObject) : Void*
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

    # Number Protocols
    fun number_check = PyNumber_Check(o : PyObject) : Int
    fun number_add = PyNumber_Add(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_subtract = PyNumber_Subtract(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_multiply = PyNumber_Multiply(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_matrix_multiply = PyNumber_MatrixMultiply(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_floor_divide = PyNumber_FloorDivide(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_true_divide = PyNumber_TrueDivide(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_remainder = PyNumber_Remainder(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_divmod = PyNumber_Divmod(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_power = PyNumber_Power(o1 : PyObject, o2 : PyObject, o3 : PyObject) : PyObject
    fun number_negative = PyNumber_Negative(o : PyObject) : PyObject
    fun number_positive = PyNumber_Positive(o : PyObject) : PyObject
    fun number_absolute = PyNumber_Absolute(o : PyObject) : PyObject
    fun number_invert = PyNumber_Invert(o : PyObject) : PyObject
    fun number_lshift = PyNumber_Lshift(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_rshift = PyNumber_Rshift(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_and = PyNumber_And(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_xor = PyNumber_Xor(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_or = PyNumber_Or(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_add = PyNumber_InPlaceAdd(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_subtract = PyNumber_InPlaceSubtract(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_multiply = PyNumber_InPlaceMultiply(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_matrix_multiply = PyNumber_InPlaceMatrixMultiply(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_floor_divide = PyNumber_InPlaceFloorDivide(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_true_divide = PyNumber_InPlaceTrueDivide(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_remainder = PyNumber_InPlaceRemainder(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_power = PyNumber_InPlacePower(o1 : PyObject, o2 : PyObject, o3 : PyObject) : PyObject
    fun number_in_place_lshift = PyNumber_InPlaceLshift(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_rshift = PyNumber_InPlaceRshift(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_and = PyNumber_InPlaceAnd(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_xor = PyNumber_InPlaceXor(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_in_place_or = PyNumber_InPlaceOr(o1 : PyObject, o2 : PyObject) : PyObject
    fun number_long = PyNumber_Long(o : PyObject) : PyObject
    fun number_float = PyNumber_Float(o : PyObject) : PyObject
    fun number_index = PyNumber_Index(o : PyObject) : PyObject
    fun number_to_base = PyNumber_ToBase(n : PyObject, base : Int) : PyObject
    fun number_as_ssize_t = PyNumber_AsSsize_t(o : PyObject, exc : PyObject) : Long
    fun index_check = PyIndex_Check(o : PyObject) : Int

    # Sequence Protocols
    fun sequence_check = PySequence_Check(o : PyObject) : Int
    fun sequence_size = PySequence_Size(o : PyObject) : Long
    fun sequence_length = PySequence_Length(o : PyObject) : Long
    fun sequence_concat = PySequence_Concat(o1 : PyObject, o2 : PyObject) : PyObject
    fun sequence_repeat = PySequence_Repeat(o : PyObject, count : Long) : PyObject
    fun sequence_in_place_concat = PySequence_InPlaceConcat(o1 : PyObject, o2 : PyObject) : PyObject
    fun sequence_in_place_repeat = PySequence_InPlaceRepeat(o : PyObject, count : Long) : PyObject
    fun sequence_get_item = PySequence_GetItem(o : PyObject, i : Long) : PyObject
    fun sequence_get_slice = PySequence_GetSlice(o : PyObject, i1 : Long, i2 : Long) : PyObject
    fun sequence_set_item = PySequence_SetItem(o : PyObject, i : Long, v : PyObject) : Int
    fun sequence_del_item = PySequence_DelItem(o : PyObject, i : Long) : Int
    fun sequence_set_slice = PySequence_SetSlice(o : PyObject, i1 : Long, i2 : Long, v : PyObject) : Int
    fun sequence_del_slice = PySequence_DelSlice(o : PyObject, i1 : Long, i2 : Long) : Int
    fun sequence_count = PySequence_Count(o : PyObject, value : PyObject) : Long
    fun sequence_contains = PySequence_Contains(o : PyObject, value : PyObject) : Int
    fun sequence_index = PySequence_Index(o : PyObject, value : PyObject) : Long
    fun sequence_list = PySequence_List(o : PyObject) : PyObject
    fun sequence_tuple = PySequence_Tuple(o : PyObject) : PyObject
    fun sequence_fast = PySequence_Fast(o : PyObject, m : Char*) : PyObject

    # Mapping Protocols
    fun mapping_check = PyMapping_Check(o : PyObject) : Int
    fun mapping_size = PyMapping_Size(o : PyObject) : Long
    fun mapping_length = PyMapping_Length(o : PyObject) : Long
    fun mapping_get_item_string = PyMapping_GetItemString(o : PyObject, key : Char*) : PyObject
    fun mapping_get_optional_item = PyMapping_GetOptionalItem(obj : PyObject, key : PyObject, result : PyObject**) : Int
    fun mapping_get_optional_item_string = PyMapping_GetOptionalItemString(obj : PyObject, key : Char*, result : PyObject**) : Int
    fun mapping_set_item_string = PyMapping_SetItemString(o : PyObject, key : Char*, v : PyObject) : Int
    fun mapping_has_key_with_error = PyMapping_HasKeyWithError(o : PyObject, key : PyObject) : Int
    fun mapping_has_key_string_with_error = PyMapping_HasKeyStringWithError(o : PyObject, key : Char*) : Int
    fun mapping_has_key = PyMapping_HasKey(o : PyObject, key : PyObject) : Int
    fun mapping_has_key_string = PyMapping_HasKeyString(o : PyObject, key : Char*) : Int
    fun mapping_keys = PyMapping_Keys(o : PyObject) : PyObject
    fun mapping_values = PyMapping_Values(o : PyObject) : PyObject
    fun mapping_items = PyMapping_Items(o : PyObject) : PyObject

    # Iterator Protocols
    fun iter_check = PyIter_Check(o : PyObject) : Int
    fun aiter_check = PyAIter_Check(o : PyObject) : Int
    fun iter_next = PyIter_Next(o : PyObject) : PyObject
  end
end
