module Crython
  # https://github.com/python/cpython/blob/main/Include/boolobject.h

  @[Link("python3")]
  lib LibPython
    fun bool_check = PyBool_Check(o : PyObject) : Int
    fun bool_from_long = PyBool_FromLong(i : Long) : PyObject
  end
end
