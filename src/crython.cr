require "./crython/libpython"
require "./crython/error"
require "./crython/*"
require "./crython/cr2py/*"
require "./crython/py2cr/*"

module Crython
  def self.import(name : String) : PyObject
    debug_log("import:start name=#{name} session_token=#{session_token} active=#{initialized?}")
    mod = Crython.with_gil do
      mod_ptr = LibPython.import(name)
      e = LibPython.err_occurred
      if mod_ptr.null? || !e.null?
        error_info = extract_python_error
        debug_log("import:error name=#{name} error=#{error_info}")
        raise ImportError.new(name, error_info)
      end
      PyObject.new(mod_ptr, need_decref: true)
    end
    debug_log("import:ok name=#{name}")
    mod
  end

  def self.import?(name : String) : PyObject?
    debug_log("import?:start name=#{name} session_token=#{session_token} active=#{initialized?}")
    mod = Crython.with_gil do
      mod_ptr = LibPython.import(name)
      e = LibPython.err_occurred
      if mod_ptr.null? || !e.null?
        error_info = extract_python_error
        debug_log("import?:nil name=#{name} error=#{error_info}")
        nil
      else
        PyObject.new(mod_ptr, need_decref: true)
      end
    end
    debug_log("import?:ok name=#{name}") unless mod.nil?
    mod
  end

  def self.slice_full : PyObject
    with_gil do
      n1 = none_newref
      n2 = none_newref
      n3 = none_newref
      begin
        sf = LibPython.slice_new(n1, n2, n3)
        PyObject.new(sf, need_decref: true)
      ensure
        LibPython.decref(n1)
        LibPython.decref(n2)
        LibPython.decref(n3)
      end
    end
  end
end
