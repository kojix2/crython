struct Tuple
  def to_py : Crython::PyObject
    Crython.with_gil do
      tuple = Crython::LibPython.tuple_new(self.size)
      self.each_with_index do |item, index|
        py_item = item.to_py
        py_item_raw = py_item.to_unsafe
        # Keep py_item's own reference and give the stealing API a new one.
        Crython::LibPython.incref(py_item_raw)

        if Crython::LibPython.tuple_set_item(tuple, index, py_item_raw) < 0
          Crython::LibPython.decref(tuple)
          error_info = Crython.extract_python_error
          raise Crython::CrythonError.new("Failed to insert item into tuple#{error_info ? ": #{error_info}" : ""}")
        end
      end
      Crython::PyObject.from_owned(tuple)
    end
  end
end
