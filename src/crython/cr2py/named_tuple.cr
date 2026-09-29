struct NamedTuple
  def to_py : Crython::PyObject
    Crython.with_gil do
      dict = Crython::LibPython.dict_new
      self.each do |key, value|
        py_key = key.to_py
        py_value = value.to_py
        py_key_raw = py_key.to_unsafe
        py_value_raw = py_value.to_unsafe
        if Crython::LibPython.dict_set_item(dict, py_key_raw, py_value_raw) < 0
          Crython::LibPython.decref(dict)
          error_info = Crython.extract_python_error
          raise Crython::CrythonError.new("Failed to insert item into dictionary#{error_info ? ": #{error_info}" : ""}")
        end
      end
      Crython::PyObject.from_owned(dict)
    end
  end
end
