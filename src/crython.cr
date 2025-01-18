require "./crython/libpython"
require "./crython/libcrython"
require "./crython/env"
require "./crython/err"
require "./crython/object"
require "./crython/list"

module Crython
  VERSION = "0.1.0"

  def self.import_module(name : String) : PyObject
    PyObject.new(LibPython.import_module(name))
  end
end
