module Crython
  # Module for converting Python objects to Crystal types
  module Py2Cr
    # Convert a Python object to a Crystal Int32
    def self.to_int32(pyobject : PyObject) : Int32
      type_name = pyobject.get_type_name
      unless type_name == "<class 'int'>"
        raise TypeError.new(type_name, "Int32", "Expected Python int")
      end

      value = LibPython.long_as_long(pyobject.raw)
      if LibPython.err_occurred
        error_info = Crython.extract_python_error
        LibPython.err_clear
        raise ValueError.new("Integer overflow: #{error_info}")
      end

      value.to_i32
    end

    # Convert a Python object to a Crystal Int64
    def self.to_int64(pyobject : PyObject) : Int64
      type_name = pyobject.get_type_name
      unless type_name == "<class 'int'>"
        raise TypeError.new(type_name, "Int64", "Expected Python int")
      end

      value = LibPython.long_as_long_long(pyobject.raw)
      if LibPython.err_occurred
        error_info = Crython.extract_python_error
        LibPython.err_clear
        raise ValueError.new("Integer overflow: #{error_info}")
      end

      value
    end

    # Convert a Python object to a Crystal Float64
    def self.to_float64(pyobject : PyObject) : Float64
      type_name = pyobject.get_type_name
      unless type_name == "<class 'float'>"
        raise TypeError.new(type_name, "Float64", "Expected Python float")
      end

      value = LibPython.float_as_double(pyobject.raw)
      if LibPython.err_occurred
        error_info = Crython.extract_python_error
        LibPython.err_clear
        raise ValueError.new("Float conversion error: #{error_info}")
      end

      value
    end

    # Convert a Python object to a Crystal String
    def self.to_string(pyobject : PyObject) : String
      type_name = pyobject.get_type_name
      unless type_name == "<class 'str'>"
        raise TypeError.new(type_name, "String", "Expected Python str")
      end

      ptr = LibPython.unicode_as_utf8(pyobject.raw)
      if ptr.null?
        raise ValueError.new("Failed to convert Python string to UTF-8")
      end

      String.new(ptr)
    end

    # Convert a Python object to a Crystal Bool
    def self.to_bool(pyobject : PyObject) : Bool
      type_name = pyobject.get_type_name
      unless type_name == "<class 'bool'>"
        raise TypeError.new(type_name, "Bool", "Expected Python bool")
      end

      LibPython.object_is_true(pyobject.raw) != 0
    end

    # Check if a Python object is None
    def self.is_none?(pyobject : PyObject) : Bool
      type_name = pyobject.get_type_name
      type_name == "<class 'NoneType'>"
    end
  end
end

# Extension methods for PyObject
class Crython::PyObject
  # Helper method to get Python object type name
  def get_type_name : String
    type_obj = LibPython.object_type(@raw)
    if type_obj.null?
      return "unknown"
    end

    type_str = LibPython.object_str(type_obj)
    if type_str.null?
      LibPython.decref(type_obj)
      return "unknown"
    end

    type_name = String.new(LibPython.unicode_as_utf8(type_str))
    LibPython.decref(type_str)
    LibPython.decref(type_obj)

    type_name
  end

  # Access the raw Python object pointer
  def raw
    @raw
  end

  # Convert to Crystal Int32
  def to_i32 : Int32
    Crython::Py2Cr.to_int32(self)
  end

  # Convert to Crystal Int64
  def to_i64 : Int64
    Crython::Py2Cr.to_int64(self)
  end

  # Convert to Crystal Float64
  def to_f64 : Float64
    Crython::Py2Cr.to_float64(self)
  end

  # Convert to Crystal String
  def to_s(io : IO) : Nil
    s = LibPython.object_str(@raw)
    ptr = LibPython.unicode_as_utf8(s)
    io.print String.new(ptr)
    LibPython.decref(s)
  end

  # Convert to Crystal Bool
  def to_b : Bool
    Crython::Py2Cr.to_bool(self)
  end

  # Convert to appropriate Crystal type
  def to_cr
    type_name = get_type_name
    case type_name
    when "<class 'int'>"
      to_i64
    when "<class 'float'>"
      to_f64
    when "<class 'str'>"
      to_s
    when "<class 'bool'>"
      to_b
    when "<class 'NoneType'>"
      nil
    else
      raise TypeError.new(type_name, "Crystal type", "Unsupported Python type")
    end
  end
end
