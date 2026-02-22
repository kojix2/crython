struct Nil
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.build_value("")
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Nil
    nil
  end
end
