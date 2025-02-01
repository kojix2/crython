struct UInt8
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("I", self)
    Crython::PyObject.new(ptr)
  end
end

struct Int8
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("i", self)
    Crython::PyObject.new(ptr)
  end
end

struct UInt16
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("H", self)
    Crython::PyObject.new(ptr)
  end
end

struct Int16
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("h", self)
    Crython::PyObject.new(ptr)
  end
end

struct UInt32
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("I", self)
    Crython::PyObject.new(ptr)
  end
end

struct Int32
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("i", self)
    Crython::PyObject.new(ptr)
  end
end

struct UInt64
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("K", self)
    Crython::PyObject.new(ptr)
  end
end

struct Int64
  def to_py : Crython::PyObject
    ptr = :LibPython.build_value("k", self)
    Crython::PyObject.new(ptr)
  end
end

struct UInt128
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("N", self)
    Crython::PyObject.new(ptr)
  end
end

struct Int128
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("n", self)
    Crython::PyObject.new(ptr)
  end
end

struct Float32
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("f", self)
    Crython::PyObject.new(ptr)
  end
end

struct Float64
  def to_py : Crython::PyObject
    ptr = LibPython.build_value("d", self)
    Crython::PyObject.new(ptr)
  end
end
