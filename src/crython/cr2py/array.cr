class Array(T)
  def to_py : Crython::PyObject
    list = Crython::LibPython.list_new(self.size)
    self.each_with_index do |item, index|
      # item.to_py returns a new reference.
      # PyList_SetItem steals a reference, so after passing the raw pointer
      # the ownership is transferred to the list. We therefore mark the
      # wrapper as not needing decref to avoid double free.
      py_item = item.to_py
      Crython::LibPython.list_set_item(list, index, py_item.to_unsafe)
      py_item.need_decref = false
    end
    Crython::PyObject.new(list, need_decref: true)
  end

  def self.new(pyobject : Crython::PyObject) : Array(T)
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
          py_obj = Crython::PyObject.new(py_item)
          T.new(py_obj)
        end
      when "<class 'tuple'>"
        size = Crython::LibPython.tuple_size(pyobject)
        Array.new(size) do |index|
          py_item = Crython::LibPython.tuple_get_item(pyobject, index)
          py_obj = Crython::PyObject.new(py_item)
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
