module Crython
  # https://github.com/python/cpython/blob/main/Include/pystate.h

  @[Link("python3")]
  lib LibPython
    alias PyGILState_STATE = LibC::Int

    fun gil_state_ensure = PyGILState_Ensure : PyGILState_STATE
    fun gil_state_release = PyGILState_Release(state : PyGILState_STATE)
  end
end
