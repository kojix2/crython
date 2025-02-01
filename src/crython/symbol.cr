struct Symbol
  # Currently, just convert the symbol to a string
  def to_py : Crython::PyObject
    to_s.to_py
  end
end
