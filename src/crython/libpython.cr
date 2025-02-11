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

    alias Py_ssize_t = LibC::SSizeT
    alias FILE = Void*
  end
end

require "./libpython/*"
