module Crython
  # Module for converting Python collection objects to Crystal types
  module Py2Cr
    # Convert a Python list to a Crystal Array
    def self.to_array(pyobject : PyObject, element_type : T.class) : Array(T) forall T
      type_name = pyobject.get_type_name
      unless type_name == "<class 'list'>"
        raise TypeError.new(type_name, "Array", "Expected Python list")
      end

      size = LibPython.list_size(pyobject.raw)
      result = Array(T).new(size)

      size.times do |i|
        item = LibPython.list_get_item(pyobject.raw, i)
        if item.null?
          error_info = Crython.extract_python_error
          raise ValueError.new("Failed to get list item at index #{i}#{error_info ? " - #{error_info}" : ""}")
        end

        # list_get_item returns a borrowed reference. Own it explicitly.
        LibPython.incref(item)
        py_item = PyObject.new(item, need_decref: true)

        # Convert the item to the specified Crystal type
        result << T.new(py_item)
      end

      result
    end

    # Convert a Python tuple to a Crystal Tuple
    def self.to_tuple(pyobject : PyObject, *element_types) : Tuple
      type_name = pyobject.get_type_name
      unless type_name == "<class 'tuple'>"
        raise TypeError.new(type_name, "Tuple", "Expected Python tuple")
      end

      size = LibPython.tuple_size(pyobject.raw)
      if size != element_types.size
        raise ValueError.new("Tuple size mismatch: Python tuple has #{size} elements, but expected #{element_types.size}")
      end

      # Create an array to hold the converted values
      none_obj = PyObject.new(LibPython.build_value(""), need_decref: true)
      values = [] of typeof(element_types[0].new(none_obj))
      if none_obj.need_decref
        LibPython.decref(none_obj.raw)
        none_obj.need_decref = false
      end

      size.times do |i|
        item = LibPython.tuple_get_item(pyobject.raw, i)
        if item.null?
          error_info = Crython.extract_python_error
          raise ValueError.new("Failed to get tuple item at index #{i}#{error_info ? " - #{error_info}" : ""}")
        end

        # tuple_get_item returns a borrowed reference. Own it explicitly.
        LibPython.incref(item)
        py_item = PyObject.new(item, need_decref: true)

        # Convert the item to the specified Crystal type
        values << element_types[i].new(py_item)
      end

      Tuple.new(values)
    end

    # Convert a Python dict to a Crystal Hash
    def self.to_hash(pyobject : PyObject, key_type : K.class, value_type : V.class) : Hash(K, V) forall K, V
      type_name = pyobject.get_type_name
      unless type_name == "<class 'dict'>"
        raise TypeError.new(type_name, "Hash", "Expected Python dict")
      end

      result = Hash(K, V).new

      # Get dict keys
      keys = LibPython.dict_keys(pyobject.raw)
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
        value_item = LibPython.dict_get_item(pyobject.raw, key_item)
        if value_item.null?
          LibPython.decref(keys)
          LibPython.decref(keys_list)
          error_info = Crython.extract_python_error
          raise ValueError.new("Failed to get dict value for key at index #{i}#{error_info ? " - #{error_info}" : ""}")
        end

        # dict/list getters return borrowed references. Own them explicitly.
        LibPython.incref(key_item)
        LibPython.incref(value_item)
        py_key = PyObject.new(key_item, need_decref: true)
        py_value = PyObject.new(value_item, need_decref: true)

        result[K.new(py_key)] = V.new(py_value)
      end

      # Clean up
      LibPython.decref(keys)
      LibPython.decref(keys_list)

      result
    end
  end
end

# Extension methods for PyObject
class Crython::PyObject
  # Convert to Crystal Array
  def to_a(element_type : T.class) : Array(T) forall T
    Crython::Py2Cr.to_array(self, element_type)
  end

  # Convert to Crystal Hash
  def to_h(key_type : K.class, value_type : V.class) : Hash(K, V) forall K, V
    Crython::Py2Cr.to_hash(self, key_type, value_type)
  end
end
