require "./crython/libpython"
require "./crython/error"
require "./crython/*"
require "./crython/cr2py/*"
require "./crython/py2cr/*"

module Crython
  def self.import(name : String) : PyObject
    debug_log("import:start name=#{name} active=#{initialized?}")
    mod = Crython.with_gil do
      mod_ptr = LibPython.import(name)
      e = LibPython.err_occurred
      if mod_ptr.null? || !e.null?
        python_error = capture_python_error
        error_info = python_error.try &.to_s
        debug_log("import:error name=#{name} error=#{error_info}")
        raise ImportError.new(name, error_info, python_error)
      end
      PyObject.from_owned(mod_ptr)
    end
    debug_log("import:ok name=#{name}")
    mod
  end

  def self.import?(name : String) : PyObject?
    debug_log("import?:start name=#{name} active=#{initialized?}")
    mod = Crython.with_gil do
      mod_ptr = LibPython.import(name)
      e = LibPython.err_occurred
      if mod_ptr.null? || !e.null?
        python_error = capture_python_error
        if python_error && python_error.type_name == "ModuleNotFoundError" && python_error.name == name
          debug_log("import?:nil name=#{name} error=#{python_error}")
          nil
        else
          raise ImportError.new(name, python_error.try(&.to_s), python_error)
        end
      else
        PyObject.from_owned(mod_ptr)
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
        PyObject.from_owned(sf)
      ensure
        LibPython.decref(n1)
        LibPython.decref(n2)
        LibPython.decref(n3)
      end
    end
  end
end
