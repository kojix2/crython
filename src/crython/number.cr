struct UInt8
  def to_py
    LibPython.build_value("I", self)
  end
end

struct Int8
  def to_py
    LibPython.build_value("i", self)
  end
end

struct UInt16
  def to_py
    LibPython.build_value("H", self)
  end
end

struct Int16
  def to_py
    LibPython.build_value("h", self)
  end
end

struct UInt32
  def to_py
    LibPython.build_value("I", self)
  end
end

struct Int32
  def to_py
    LibPython.build_value("i", self)
  end
end

struct UInt64
  def to_py
    LibPython.build_value("K", self)
  end
end

struct Int64
  def to_py
    LibPython.build_value("k", self)
  end
end

struct UInt128
  def to_py
    LibPython.build_value("N", self)
  end
end

struct Int128
  def to_py
    LibPython.build_value("n", self)
  end
end

struct Float32
  def to_py
    LibPython.build_value("f", self)
  end
end

struct Float64
  def to_py
    LibPython.build_value("d", self)
  end
end

struct Bool
  def to_py
    LibPython.build_value("O", self ? LibPython.Py_True : LibPython.Py_False)
  end
end
