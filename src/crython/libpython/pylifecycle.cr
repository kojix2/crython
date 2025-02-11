module Crython
  # https://github.com/python/cpython/blob/main/Include/pylifecycle.h

  @[Link("python3")]
  lib LibPython
    # Initialization and Finalization
    fun init = Py_Initialize
    fun init_ex = Py_InitializeEx(initsigs : Int)
    fun is_initialized = Py_IsInitialized : Int
    fun finalize = Py_Finalize
    fun finalize_ex = Py_FinalizeEx : Int

    # Python Home
    fun set_python_home = Py_SetPythonHome(home : Char*)
    fun get_python_home = Py_GetPythonHome : Char*

    # Version
    fun get_version = Py_GetVersion : Char*
    fun get_compiler = Py_GetCompiler : Char*
    fun get_build_info = Py_GetBuildInfo : Char*
  end
end
