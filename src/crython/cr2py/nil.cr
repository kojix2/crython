struct Nil
  def to_py : Crython::PyObject
    ptr = Crython.none_newref
    Crython::PyObject.from_owned(ptr)
  end

  def self.new(pyobject : Crython::PyObject) : Nil
    nil
  end
end
