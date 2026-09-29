module Crython
  # https://github.com/python/cpython/blob/main/Include/ceval.h

  lib LibPython
    fun eval_save_thread = PyEval_SaveThread : Void*
    fun eval_eval_code = PyEval_EvalCode(code : PyObject, globals : PyObject, locals : PyObject) : PyObject
  end
end
