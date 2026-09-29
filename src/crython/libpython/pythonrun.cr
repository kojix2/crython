module Crython
  # https://github.com/python/cpython/blob/main/Include/cpython/pythonrun.h

  lib LibPython
    fun run_simple_string = PyRun_SimpleString(str : Char*) : Int
    fun compile_string = Py_CompileString(str : Char*, file : Char*, start : Int) : PyObject
  end
end
