require "./crython/libpython"
require "./crython/error"
require "./crython/*"
require "./crython/cr2py/*"
require "./crython/py2cr/*"

module Crython
  def self.import(name : String) : PyObject
    debug_log("import:start name=#{name} session_id=#{session_id} active=#{initialized?}")
    state = LibPython.gil_state_ensure
    mod_ptr = begin
      LibPython.import(name)
    ensure
      LibPython.gil_state_release(state)
    end
    mod = PyObject.new(mod_ptr)
    e = LibPython.err_occurred
    if !e.null?
      error_info = extract_python_error
      debug_log("import:error name=#{name} error=#{error_info}")
      LibPython.err_print
      raise ImportError.new(name, error_info)
    end
    debug_log("import:ok name=#{name} ptr_null=#{mod_ptr.null?}")
    mod
  end

  def self.slice_full : PyObject
    state = LibPython.gil_state_ensure
    begin
      n = LibPython.build_value("")
      sf = LibPython.slice_new(n, n, n)
      LibPython.decref(n)
      PyObject.new(sf)
    ensure
      LibPython.gil_state_release(state)
    end
  end
end
