struct Nil
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("")
    Crython::PyObject.new(ptr, need_decref: true)
  end
end
