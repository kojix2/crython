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
    when "<class 'list'>"
      to_list
    when "<class 'tuple'>"
      to_tuple
    when "<class 'dict'>"
      to_dict
    when "<class 'complex'>"
      to_complex
    else
      raise TypeError.new(type_name, "Crystal type", "Unsupported Python type")
    end
  end

  # Convert Python list to Crystal Array(PyObject)
  def to_list : Array(PyObject)
    size = LibPython.list_size(@raw)
    result = Array(PyObject).new(size)

    size.times do |i|
      item = LibPython.list_get_item(@raw, i)
      if item.null?
        error_info = Crython.extract_python_error
        raise ValueError.new("Failed to get list item at index #{i}#{error_info ? " - #{error_info}" : ""}")
      end

      # We don't need to decref item because list_get_item returns a borrowed reference
      py_item = PyObject.new(item)
      result << py_item
    end

    result
  end

  # Convert Python tuple to Crystal Array(PyObject)
  def to_tuple : Array(PyObject)
    size = LibPython.tuple_size(@raw)
    result = Array(PyObject).new(size)

    size.times do |i|
      item = LibPython.tuple_get_item(@raw, i)
      if item.null?
        error_info = Crython.extract_python_error
        raise ValueError.new("Failed to get tuple item at index #{i}#{error_info ? " - #{error_info}" : ""}")
      end

      # We don't need to decref item because tuple_get_item returns a borrowed reference
      py_item = PyObject.new(item)
      result << py_item
    end

    result
  end

  # Convert Python dict to Crystal Hash(PyObject, PyObject)
  def to_dict : Hash(PyObject, PyObject)
    result = Hash(PyObject, PyObject).new

    # Get dict keys
    keys = LibPython.dict_keys(@raw)
    if keys.null?
      error_info = Crython.extract_python_error
      raise ValueError.new("Failed to get dict keys#{error_info ? " - #{error_info}" : ""}")
    end

    # Convert keys to a list for iteration
    keys_list = LibPython.sequence_list(keys)
    if keys_list.null?
      LibPython.decref(keys)
      error_info = Crython.extract_python_error
      raise ValueError.new("Failed to convert dict keys to list#{error_info ? " - #{error_info}" : ""}")
    end

    # Get the size of the keys list
    size = LibPython.list_size(keys_list)

    # Iterate over the keys
    size.times do |i|
      # Get the key
      key_item = LibPython.list_get_item(keys_list, i)
      if key_item.null?
        LibPython.decref(keys)
        LibPython.decref(keys_list)
        error_info = Crython.extract_python_error
        raise ValueError.new("Failed to get dict key at index #{i}#{error_info ? " - #{error_info}" : ""}")
      end

      # Get the value
      value_item = LibPython.dict_get_item(@raw, key_item)
      if value_item.null?
        LibPython.decref(keys)
        LibPython.decref(keys_list)
        error_info = Crython.extract_python_error
        raise ValueError.new("Failed to get dict value for key at index #{i}#{error_info ? " - #{error_info}" : ""}")
      end

      # Convert the key and value to PyObject
      py_key = PyObject.new(key_item)
      py_value = PyObject.new(value_item)

      result[py_key] = py_value
    end

    # Clean up
    LibPython.decref(keys)
    LibPython.decref(keys_list)

    result
  end

  # Convert Python complex to Crystal Complex
  def to_complex : Complex
    real = LibPython.complex_real_as_double(@raw)
    imag = LibPython.complex_imag_as_double(@raw)
    Complex.new(real, imag)
  end
end
