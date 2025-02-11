module Crython
  # https://github.com/python/cpython/blob/main/Include/ceval.h

  @[Link("python3")]
  lib LibPython
    fun eval_eval_code = PyEval_EvalCode(code : PyObject, globals : PyObject, locals : PyObject) : PyObject
  end
end
