struct NamedTuple
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
          if Crython::LibPython.dict_set_item(dict, py_key.to_unsafe, py_value.to_unsafe) < 0
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
end
