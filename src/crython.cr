require "./crython/libpython"
require "./crython/libcrython"
require "./crython/*"

module Crython
  VERSION = "0.1.0"

  def self.import(name : String) : PyObject
    mod = PyObject.new(LibPython.import(name))
    e = LibPython.err_occurred
    if !e.null?
      LibPython.err_print
      raise "Error importing module: #{name}"
    end
    mod
  end

  def self.slice_full : PyObject
    PyObject.new(LibCrython.slice_full)
  end
end
