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
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_unsigned_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : UInt8
    Crython.with_gil do
      Crython::LibPython.long_as_unsigned_long(pyobject).to_u8
    end
  end
end

struct Int8
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Int8
    Crython.with_gil do
      Crython::LibPython.long_as_long(pyobject).to_i8
    end
  end
end

struct UInt16
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_unsigned_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : UInt16
    Crython.with_gil do
      Crython::LibPython.long_as_unsigned_long(pyobject).to_u16
    end
  end
end

struct Int16
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Int16
    Crython.with_gil do
      Crython::LibPython.long_as_long(pyobject).to_i16
    end
  end
end

struct UInt32
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_unsigned_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : UInt32
    Crython.with_gil do
      Crython::LibPython.long_as_unsigned_long(pyobject).to_u32
    end
  end
end

struct Int32
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Int32
    Crython.with_gil do
      Crython::LibPython.long_as_long(pyobject).to_i32
    end
  end
end

struct UInt64
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_unsigned_long_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : UInt64
    Crython.with_gil do
      Crython::LibPython.long_as_unsigned_long_long(pyobject).to_u64
    end
  end
end

struct Int64
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.long_from_long_long(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Int64
    Crython.with_gil do
      Crython::LibPython.long_as_long_long(pyobject).to_i64
    end
  end
end

struct UInt128
  def to_py : Crython::PyObject
    Crython.with_gil do
      str_repr = self.to_s
      py_str = Crython::LibPython.unicode_from_string(str_repr)
      ptr = begin
        Crython::LibPython.long_from_unicode_object(py_str, 10)
      ensure
        Crython::LibPython.decref(py_str)
      end
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : UInt128
    Crython.with_gil do
      py_str = Crython::LibPython.object_str(pyobject)
      begin
        cstr = Crython::LibPython.unicode_as_utf8(py_str)
        str_repr = String.new(cstr)
        str_repr.to_u128
      ensure
        Crython::LibPython.decref(py_str)
      end
    end
  end
end

struct Int128
  def to_py : Crython::PyObject
    Crython.with_gil do
      str_repr = self.to_s
      py_str = Crython::LibPython.unicode_from_string(str_repr)
      ptr = begin
        Crython::LibPython.long_from_unicode_object(py_str, 10)
      ensure
        Crython::LibPython.decref(py_str)
      end
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Int128
    Crython.with_gil do
      py_str = Crython::LibPython.object_str(pyobject)
      begin
        cstr = Crython::LibPython.unicode_as_utf8(py_str)
        str_repr = String.new(cstr)
        str_repr.to_i128
      ensure
        Crython::LibPython.decref(py_str)
      end
    end
  end
end

struct Float32
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.float_from_double(self.to_f64)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Float32
    Crython.with_gil do
      Crython::LibPython.float_as_double(pyobject).to_f32
    end
  end
end

struct Float64
  def to_py : Crython::PyObject
    Crython.with_gil do
      ptr = Crython::LibPython.float_from_double(self)
      Crython::PyObject.new(ptr, need_decref: true)
    end
  end

  def self.new(pyobject : Crython::PyObject) : Float64
    Crython.with_gil do
      Crython::LibPython.float_as_double(pyobject)
    end
  end
end
