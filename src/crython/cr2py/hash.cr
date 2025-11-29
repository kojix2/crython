class Hash(K, V)
  def to_py : Crython::PyObject
    dict = Crython::LibPython.dict_new
    self.each do |key, value|
      # key.to_py / value.to_py return new references.
      # PyDict_SetItem does not steal references; it increments the
      # reference counts of key and value internally. We must decref the
      # temporary references we own after the call.
      py_key = key.to_py
      py_value = value.to_py
      result = Crython::LibPython.dict_set_item(dict, py_key.to_unsafe, py_value.to_unsafe)
      # Check if insertion was successful
      if result < 0
        Crython::LibPython.decref(py_key.to_unsafe)
        Crython::LibPython.decref(py_value.to_unsafe)
        Crython::LibPython.decref(dict)
        if Crython::LibPython.err_occurred
          Crython::LibPython.err_print
        end
        raise "Failed to insert item into dictionary"
      end
      Crython::LibPython.decref(py_key.to_unsafe)
      Crython::LibPython.decref(py_value.to_unsafe)
      py_key.need_decref = false
      py_value.need_decref = false
    end
    Crython::PyObject.new(dict, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Hash(K, V)
    # Check if it's a dict
    type_obj = Crython::LibPython.object_type(pyobject)
    if type_obj.null?
      raise "Failed to get type object"
    end

    begin
      type_str = Crython::LibPython.object_str(type_obj)
      if type_str.null?
        raise "Failed to get type name"
      end

      begin
        type_name = String.new(Crython::LibPython.unicode_as_utf8(type_str))
      ensure
        Crython::LibPython.decref(type_str)
      end

      if type_name == "<class 'dict'>"
        key_ptr = Crython::LibPython::PyObject.null
        value_ptr = Crython::LibPython::PyObject.null
        pos = 0_i64

        hash = Hash(K, V).new
        while Crython::LibPython.dict_next(pyobject, pointerof(pos), pointerof(key_ptr), pointerof(value_ptr)) != 0
          py_key = Crython::PyObject.new(key_ptr)
          py_value = Crython::PyObject.new(value_ptr)

          # Convert key and value to types K and V
          key = K.new(py_key)
          value = V.new(py_value)

          hash[key] = value
        end
        hash
      else
        # Try to convert to hash using to_cr
        py_hash = pyobject.to_cr
        if py_hash.is_a?(Hash)
          # Convert each key and value to types K and V
          result_hash = Hash(K, V).new
          py_hash.each do |k, v|
            key = if k.is_a?(Crython::PyObject)
                    K.new(k)
                  else
                    k.as(K)
                  end

            value = if v.is_a?(Crython::PyObject)
                      V.new(v)
                    else
                      v.as(V)
                    end

            result_hash[key] = value
          end
          result_hash
        else
          raise "Cannot convert #{type_name} to Hash(#{K}, #{V})"
        end
      end
    ensure
      Crython::LibPython.decref(type_obj) unless type_obj.nil?
    end
  end
end
