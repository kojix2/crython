class Hash(K, V)
  def to_py : Crython::PyObject
    Crython.with_gil do
      dict = Crython::LibPython.dict_new
      if dict.null?
        error_info = Crython.extract_python_error
        raise Crython::CrythonError.new("Failed to create dictionary#{error_info ? ": #{error_info}" : ""}")
      end

      complete = false
      begin
        self.each do |key, value|
          py_key = key.to_py
          py_value = value.to_py
          result = Crython::LibPython.dict_set_item(dict, py_key.to_unsafe, py_value.to_unsafe)
          if result < 0
            error_info = Crython.extract_python_error
            raise Crython::CrythonError.new("Failed to insert item into dictionary#{error_info ? ": #{error_info}" : ""}")
          end
        end
        complete = true
        Crython::PyObject.from_owned(dict)
      ensure
        Crython::LibPython.decref(dict) unless complete
      end
    end
  end

  def self.new(pyobject : Crython::PyObject) : Hash(K, V)
    Crython.with_gil do
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
            Crython::LibPython.incref(key_ptr)
            Crython::LibPython.incref(value_ptr)
            py_key = Crython::PyObject.from_owned(key_ptr)
            py_value = Crython::PyObject.from_owned(value_ptr)

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
end
