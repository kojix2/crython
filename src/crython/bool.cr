struct Bool
  def to_py
    LibPython.build_value("O", self ? LibCrython.py_true : LibCrython.py_false)
  end
end
