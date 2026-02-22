struct Nil
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("")
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Nil
    nil
  end
end
