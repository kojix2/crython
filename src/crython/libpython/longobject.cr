module Crython
  # https://github.com/python/cpython/blob/main/Include/longobject.h

  @[Link("python3")]
  lib LibPython
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
  end
end
