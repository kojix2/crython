require "./crython/libpython"
require "./crython/error"
require "./crython/*"
require "./crython/cr2py/*"
require "./crython/py2cr/*"

module Crython
  def self.import(name : String) : PyObject
    mod = PyObject.new(LibPython.import(name))
    e = LibPython.err_occurred
    if !e.null?
      error_info = extract_python_error
      LibPython.err_print
      raise ImportError.new(name, error_info)
    end
    mod
  end

  def self.slice_full : PyObject
    n = LibPython.build_value("")
    sf = LibPython.slice_new(n, n, n)
    LibPython.decref(n)
    PyObject.new(sf)
  end
end
