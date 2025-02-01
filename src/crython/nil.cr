struct Nil
  def to_py : Crython::PyObject
    ptr = LibCrython.none
    Crython::PyObject.new(ptr)
  end
end
