struct Bool
  def to_py : Crython::PyObject
    b = LibPython.build_value("O", self ? LibCrython.py_true : LibCrython.py_false)
    Crython::PyObject.new(b, need_decref: true)
  end
end
