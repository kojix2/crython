struct Nil
  def to_py : Crython::PyObject
    ptr = Crython.none_newref
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Nil
    nil
  end
end
