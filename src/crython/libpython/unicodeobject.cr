module Crython
  # https://github.com/python/cpython/blob/main/Include/unicodeobject.h

  @[Link("python3")]
  lib LibPython
    fun unicode_is_identifier = PyUnicode_IsIdentifier(str : PyObject) : Int
    fun unicode_from_string_and_size = PyUnicode_FromStringAndSize(str : Char*, size : LibC::SizeT) : PyObject
    fun unicode_from_string = PyUnicode_FromString(str : Char*) : PyObject
    fun unicode_from_format = PyUnicode_FromFormat(format : Char*, ...) : PyObject
    fun unicode_from_format_v = PyUnicode_FromFormatV(format : Char*, ...) : PyObject
    fun unicode_from_object = PyUnicode_FromObject(o : PyObject) : PyObject
    fun unicode_from_encoded_object = PyUnicode_FromEncodedObject(o : PyObject, encoding : Char*, errors : Char*) : PyObject
    fun unicode_get_length = PyUnicode_GetLength(o : PyObject) : Int
    fun unicode_as_utf8 = PyUnicode_AsUTF8(str : PyObject) : Char*
  end
end
