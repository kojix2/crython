module Crython
  # Module for converting Python objects to Crystal types
  module Py2Cr
    # Convert a Python object to a Crystal Int32
    def self.to_int32(pyobject : PyObject) : Int32
      Crython.with_gil do
        type_name = pyobject.get_type_name
        unless LibCrythonRuntime.long_check(pyobject.raw) != 0
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
    end

    # Convert a Python object to a Crystal Int64
    def self.to_int64(pyobject : PyObject) : Int64
      Crython.with_gil do
        type_name = pyobject.get_type_name
        unless LibCrythonRuntime.long_check(pyobject.raw) != 0
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
    end

    # Convert a Python object to a Crystal Float64
    def self.to_float64(pyobject : PyObject) : Float64
      Crython.with_gil do
        type_name = pyobject.get_type_name
        unless LibCrythonRuntime.float_check(pyobject.raw) != 0
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
    end

    # Convert a Python object to a Crystal String
    def self.to_string(pyobject : PyObject) : String
      Crython.with_gil do
        type_name = pyobject.get_type_name
        unless LibCrythonRuntime.unicode_check(pyobject.raw) != 0
          raise TypeError.new(type_name, "String", "Expected Python str")
        end

        bytesize = uninitialized LibC::SSizeT
        ptr = LibPython.unicode_as_utf8_and_size(pyobject.raw, pointerof(bytesize))
        if ptr.null?
          raise ValueError.new("Failed to convert Python string to UTF-8")
        end

        String.new(ptr, bytesize.to_i)
      end
    end

    # Convert a Python object to a Crystal Bool
    def self.to_bool(pyobject : PyObject) : Bool
      Crython.with_gil do
        type_name = pyobject.get_type_name
        unless LibCrythonRuntime.bool_check(pyobject.raw) != 0
          raise TypeError.new(type_name, "Bool", "Expected Python bool")
        end

        LibPython.object_is_true(pyobject.raw) != 0
      end
    end

    # Check if a Python object is None
    def self.is_none?(pyobject : PyObject) : Bool
      Crython.with_gil do
        type_name = pyobject.get_type_name
        LibCrythonRuntime.none_check(pyobject.raw) != 0
      end
    end
  end
end

# Extension methods for PyObject
class Crython::PyObject
  # Helper method to get Python object type name
  def get_type_name : String
    Crython.with_gil do
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
    Crython.with_gil do
      s = LibPython.object_str(@raw)
      if s.null?
        python_error = Crython.capture_python_error
        raise CrythonError.new("Error converting Python object to string#{python_error ? " - #{python_error}" : ""}", python_error)
      end
      begin
        bytesize = uninitialized LibC::SSizeT

        ptr = LibPython.unicode_as_utf8_and_size(s, pointerof(bytesize))

        if ptr.null?
          python_error = Crython.capture_python_error
          raise CrythonError.new("Error converting Python object to string#{python_error ? " - #{python_error}" : ""}", python_error)
        end
        io.print String.new(ptr, bytesize.to_i)
      ensure
        LibPython.decref(s)
      end
    end
  end

  # Convert to Crystal Bool
  def to_b : Bool
    Crython::Py2Cr.to_bool(self)
  end

  # Convert to an appropriate Crystal type, accepting Python subclasses.
  def to_cr
    Crython.with_gil do
      if LibCrythonRuntime.bool_check(@raw) != 0
        to_b
      elsif LibCrythonRuntime.long_check(@raw) != 0
        to_i64
      elsif LibCrythonRuntime.float_check(@raw) != 0
        to_f64
      elsif LibCrythonRuntime.unicode_check(@raw) != 0
        to_s
      elsif LibCrythonRuntime.none_check(@raw) != 0
        nil
      elsif LibCrythonRuntime.list_check(@raw) != 0
        to_list
      elsif LibCrythonRuntime.tuple_check(@raw) != 0
        to_tuple
      elsif LibCrythonRuntime.dict_check(@raw) != 0
        to_dict
      elsif LibCrythonRuntime.complex_check(@raw) != 0
        to_complex
      else
        raise TypeError.new(get_type_name, "Crystal type", "Unsupported Python type")
      end
    end
  end

  # Convert Python list to Crystal Array(PyObject)
  def to_list : Array(PyObject)
    Crython.with_gil do
      size = LibPython.list_size(@raw)
      result = Array(PyObject).new(size)

      size.times do |i|
        item = LibPython.list_get_item(@raw, i)
        if item.null?
          error_info = Crython.extract_python_error
          raise ValueError.new("Failed to get list item at index #{i}#{error_info ? " - #{error_info}" : ""}")
        end

        # list_get_item returns a borrowed reference. Own it explicitly.
        LibPython.incref(item)
        py_item = PyObject.from_owned(item)
        result << py_item
      end

      result
    end
  end

  # Convert Python tuple to Crystal Array(PyObject)
  def to_tuple : Array(PyObject)
    Crython.with_gil do
      size = LibPython.tuple_size(@raw)
      result = Array(PyObject).new(size)

      size.times do |i|
        item = LibPython.tuple_get_item(@raw, i)
        if item.null?
          error_info = Crython.extract_python_error
          raise ValueError.new("Failed to get tuple item at index #{i}#{error_info ? " - #{error_info}" : ""}")
        end

        # tuple_get_item returns a borrowed reference. Own it explicitly.
        LibPython.incref(item)
        py_item = PyObject.from_owned(item)
        result << py_item
      end

      result
    end
  end

  # Convert Python dict to Crystal Hash(PyObject, PyObject)
  def to_dict : Hash(PyObject, PyObject)
    Crython.with_gil do
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

        # dict/list getters return borrowed references. Own them explicitly.
        LibPython.incref(key_item)
        LibPython.incref(value_item)
        py_key = PyObject.from_owned(key_item)
        py_value = PyObject.from_owned(value_item)

        result[py_key] = py_value
      end

      # Clean up
      LibPython.decref(keys)
      LibPython.decref(keys_list)

      result
    end
  end

  # Convert Python complex to Crystal Complex
  def to_complex : Complex
    Crython.with_gil do
      real = LibPython.complex_real_as_double(@raw)
      imag = LibPython.complex_imag_as_double(@raw)
      Complex.new(real, imag)
    end
  end
end
