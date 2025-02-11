module Crython
  # https://github.com/python/cpython/blob/main/Include/abstract.h

  @[Link("python3")]
  lib LibPython
    # Object Protocols
    fun object_has_attr_string = PyObject_HasAttrString(o : PyObject, attr : Char*) : Int
    fun object_get_attr = PyObject_GetAttr(o : PyObject, attr_name : PyObject) : PyObject
    fun object_get_attr_string = PyObject_GetAttrString(o : PyObject, attr_name : Char*) : PyObject
    fun object_get_optional_attr = PyObject_GetOptionalAttr(o : PyObject, attr_name : PyObject, result : PyObject*) : Int
    fun object_get_optional_attr_string = PyObject_GetOptionalAttrString(o : PyObject, attr_name : Char*, result : PyObject*) : Int
    fun object_generic_get_attr = PyObject_GenericGetAttr(o : PyObject, name : PyObject) : PyObject
    fun object_set_attr = PyObject_SetAttr(o : PyObject, attr_name : PyObject, val : PyObject) : Int
    fun object_set_attr_string = PyObject_SetAttrString(o : PyObject, attr_name : Char*, val : PyObject) : Int
    fun object_generic_set_attr = PyObject_GenericSetAttr(o : PyObject, name : PyObject, value : PyObject) : Int
    fun object_del_attr = PyObject_DelAttr(o : PyObject, attr_name : PyObject) : Int
    fun object_del_attr_string = PyObject_DelAttrString(o : PyObject, attr_name : Char*) : Int

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
    fun object_generic_get_dict = PyObject_GenericGetDict(o : PyObject, context : Void*) : PyObject
    fun object_generic_set_dict = PyObject_GenericSetDict(o : PyObject, value : PyObject, context : Void*) : Int
    fun object_rich_compare = PyObject_RichCompare(o1 : PyObject, o2 : PyObject, opid : Int) : PyObject
    fun object_rich_compare_bool = PyObject_RichCompareBool(o1 : PyObject, o2 : PyObject, opid : Int) : Int
    fun object_format = PyObject_Format(o : PyObject, format_spec : PyObject) : PyObject
    fun object_ascii = PyObject_ASCII(o : PyObject) : PyObject
    fun object_bytes = PyObject_Bytes(o : PyObject) : PyObject
    # fun object_hash = PyObject_Hash(o : PyObject) : Py_hash_t
    # fun object_hash_not_implemented = PyObject_HashNotImplemented(o : PyObject) : Py_hash_t
    fun object_is_true = PyObject_IsTrue(o : PyObject) : Int
    fun object_not = PyObject_Not(o : PyObject) : Int
    fun object_size = PyObject_Size(o : PyObject) : Py_ssize_t
    fun object_length = PyObject_Length(o : PyObject) : Py_ssize_t
    fun object_del_item = PyObject_DelItem(o : PyObject, key : PyObject) : Int
    fun object_del_item_string = PyObject_DelItemString(o : PyObject, key : Char*) : Int
    fun object_dir = PyObject_Dir(o : PyObject) : PyObject
    fun object_get_iter = PyObject_GetIter(o : PyObject) : PyObject
    fun object_self_iter = PyObject_SelfIter(o : PyObject) : PyObject

    # Iterator Protocols
    fun iter_check = PyIter_Check(o : PyObject) : Int
    fun aiter_check = PyAIter_Check(o : PyObject) : Int
    fun iter_next = PyIter_Next(o : PyObject) : PyObject

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
    fun mapping_get_optional_item = PyMapping_GetOptionalItem(obj : PyObject, key : PyObject, result : PyObject*) : Int
    fun mapping_get_optional_item_string = PyMapping_GetOptionalItemString(obj : PyObject, key : Char*, result : PyObject*) : Int
    fun mapping_set_item_string = PyMapping_SetItemString(o : PyObject, key : Char*, v : PyObject) : Int
    fun mapping_has_key_with_error = PyMapping_HasKeyWithError(o : PyObject, key : PyObject) : Int
    fun mapping_has_key_string_with_error = PyMapping_HasKeyStringWithError(o : PyObject, key : Char*) : Int
    fun mapping_has_key = PyMapping_HasKey(o : PyObject, key : PyObject) : Int
    fun mapping_has_key_string = PyMapping_HasKeyString(o : PyObject, key : Char*) : Int
    fun mapping_keys = PyMapping_Keys(o : PyObject) : PyObject
    fun mapping_values = PyMapping_Values(o : PyObject) : PyObject
    fun mapping_items = PyMapping_Items(o : PyObject) : PyObject
  end
end
