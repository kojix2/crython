class Array(T)
  def to_py : Crython::PyObject
    Crython.with_gil do
      list = Crython::LibPython.list_new(self.size)
      if list.null?
        error_info = Crython.extract_python_error
        raise Crython::CrythonError.new("Failed to create list#{error_info ? ": #{error_info}" : ""}")
      end

      complete = false
      begin
        self.each_with_index do |item, index|
          py_item = item.to_py
          py_item_raw = py_item.to_unsafe
          # Keep py_item's own reference and give the stealing API a new one.
          Crython::LibPython.incref(py_item_raw)

          # PyList_SetItem steals this reference even when it fails.
          if Crython::LibPython.list_set_item(list, index, py_item_raw) < 0
            error_info = Crython.extract_python_error
            raise Crython::CrythonError.new("Failed to insert item into list#{error_info ? ": #{error_info}" : ""}")
          end
        end
        complete = true
        Crython::PyObject.from_owned(list)
      ensure
        Crython::LibPython.decref(list) unless complete
      end
    end
  end

  def self.new(pyobject : Crython::PyObject) : Array(T)
    Crython.with_gil do
      # Check if it's a list or tuple
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

        case type_name
        when "<class 'list'>"
          size = Crython::LibPython.list_size(pyobject)
          Array.new(size) do |index|
            py_item = Crython::LibPython.list_get_item(pyobject, index)
            Crython::LibPython.incref(py_item)
            py_obj = Crython::PyObject.from_owned(py_item)
            T.new(py_obj)
          end
        when "<class 'tuple'>"
          size = Crython::LibPython.tuple_size(pyobject)
          Array.new(size) do |index|
            py_item = Crython::LibPython.tuple_get_item(pyobject, index)
            Crython::LibPython.incref(py_item)
            py_obj = Crython::PyObject.from_owned(py_item)
            T.new(py_obj)
          end
        else
          # Try to convert to array using to_cr
          py_array = pyobject.to_cr
          if py_array.is_a?(Array)
            # Convert each element to type T
            py_array.map do |item|
              if item.is_a?(Crython::PyObject)
                T.new(item)
              else
                item.as(T)
              end
            end
          else
            raise "Cannot convert #{type_name} to Array(#{T})"
          end
        end
      ensure
        Crython::LibPython.decref(type_obj) unless type_obj.nil?
      end
    end
  end
end
