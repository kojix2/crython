module Crython

  # Note:
  # LibPython is a low-level binding to the Python C API.
  # Due to the large number of Python C functions, each function is implemented
  # in a separate file within the libpython subdirectory.
  # The libpython subdirectory contains files named according to the corresponding
  # Python C header files.
  # Here, with a few exceptions, we only include Stable ABI functions.

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

    alias Py_ssize_t = LibC::SSizeT
    alias FILE = Void*
  end
end

require "./libpython/*"
