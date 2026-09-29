module Crython
  # https://github.com/python/cpython/blob/main/Include/import.h

  lib LibPython
    fun import = PyImport_ImportModule(name : Char*) : PyObject
  end
end
