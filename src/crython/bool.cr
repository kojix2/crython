struct Bool
  def to_py : Crython::PyObject
    b = LibPython.build_value("O", self ? LibCrython.py_true : LibCrython.py_false)
    Crython::PyObject.new(b)
  end
end
