struct Number
  def +(other : Crython::PyObject) : Crython::PyObject
    other.__radd__(self)
  end

  def -(other : Crython::PyObject) : Crython::PyObject
    other.__rsub__(self)
  end

  def *(other : Crython::PyObject) : Crython::PyObject
    other.__rmul__(self)
  end

  def /(other : Crython::PyObject) : Crython::PyObject
    other.__rtruediv__(self)
  end

  def //(other : Crython::PyObject) : Crython::PyObject
    other.__rfloordiv__(self)
  end

  def %(other : Crython::PyObject) : Crython::PyObject
    other.__rmod__(self)
  end

  def **(other : Crython::PyObject) : Crython::PyObject
    other.__rpow__(self)
  end

  def <(other : Crython::PyObject) : Crython::PyObject
    to_py.__lt__(other)
  end

  def <=(other : Crython::PyObject) : Crython::PyObject
    to_py.__le__(other)
  end

  def >(other : Crython::PyObject) : Crython::PyObject
    to_py.__gt__(other)
  end

  def >=(other : Crython::PyObject) : Crython::PyObject
    to_py.__ge__(other)
  end

  def ==(other : Crython::PyObject) : Crython::PyObject
    to_py.__eq__(other)
  end

  def !=(other : Crython::PyObject) : Crython::PyObject
    to_py.__ne__(other)
  end
end

struct UInt8
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("B", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Int8
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("b", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct UInt16
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("H", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Int16
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("h", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct UInt32
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("I", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Int32
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("i", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct UInt64
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("K", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Int64
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("L", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct UInt128
  def to_py : Crython::PyObject
    str_repr = self.to_s                                # UInt128 を String に変換
    ptr = Crython::LibPython.long_from_string(str_repr, nil, 10) # 10進数の `int` に変換
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Int128
  def to_py : Crython::PyObject
    str_repr = self.to_s                                # Int128 を String に変換
    ptr = Crython::LibPython.long_from_string(str_repr, nil, 10) # 10進数の `int` に変換
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Float32
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("f", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end

struct Float64
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("d", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end
end
