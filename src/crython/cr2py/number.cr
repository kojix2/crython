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
    ptr = Crython::LibPython.long_from_unsigned_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : UInt8
    Crython::LibPython.long_as_unsigned_long(pyobject).to_u8
  end
end

struct Int8
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Int8
    Crython::LibPython.long_as_long(pyobject).to_i8
  end
end

struct UInt16
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_unsigned_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : UInt16
    Crython::LibPython.long_as_unsigned_long(pyobject).to_u16
  end
end

struct Int16
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Int16
    Crython::LibPython.long_as_long(pyobject).to_i16
  end
end

struct UInt32
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_unsigned_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : UInt32
    Crython::LibPython.long_as_unsigned_long(pyobject).to_u32
  end
end

struct Int32
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Int32
    Crython::LibPython.long_as_long(pyobject).to_i32
  end
end

struct UInt64
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_unsigned_long_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : UInt64
    Crython::LibPython.long_as_unsigned_long_long(pyobject).to_u64
  end
end

struct Int64
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.long_from_long_long(self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Int64
    Crython::LibPython.long_as_long_long(pyobject).to_i64
  end
end

struct UInt128
  def to_py : Crython::PyObject
    str_repr = self.to_s
    py_str = Crython::LibPython.unicode_from_string(str_repr)
    ptr = Crython::LibPython.long_from_unicode_object(py_str, 10)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : UInt128
    py_str = Crython::LibPython.object_str(pyobject)
    cstr = Crython::LibPython.unicode_as_utf8(py_str)
    str_repr = String.new(cstr)
    str_repr.to_u128
  end
end

struct Int128
  def to_py : Crython::PyObject
    str_repr = self.to_s
    py_str = Crython::LibPython.unicode_from_string(str_repr)
    ptr = Crython::LibPython.long_from_unicode_object(py_str, 10)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Int128
    py_str = Crython::LibPython.object_str(pyobject)
    cstr = Crython::LibPython.unicode_as_utf8(py_str)
    str_repr = String.new(cstr)
    str_repr.to_i128
  end
end

struct Float32
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("f", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Float32
    Crython::LibPython.float_as_double(pyobject).to_f32
  end
end

struct Float64
  def to_py : Crython::PyObject
    ptr = Crython::LibPython.build_value("d", self)
    Crython::PyObject.new(ptr, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Float64
    Crython::LibPython.float_as_double(pyobject)
  end
end
