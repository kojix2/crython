require "./crython/libpython"
require "./crython/libcrython"
require "./crython/env"
require "./crython/err"
require "./crython/object"
require "./crython/list"

module Crython
  VERSION = "0.1.0"

  def self.import_module(name : String) : PyObject
    mod = PyObject.new(LibPython.import_module(name))
    e = LibPython.error_occurred
    if !e.null?
      LibPython.error_print
      raise "Error importing module: #{name}"
    end
    mod
  end
end
