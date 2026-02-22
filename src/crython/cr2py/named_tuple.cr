struct NamedTuple
  def to_py : Crython::PyObject
    Crython.with_gil do
      dict = Crython::LibPython.dict_new
      self.each do |key, value|
        # key.to_py / value.to_py return new references.
        # PyDict_SetItem does not steal references; it increments the
        # reference counts of key and value internally. We must decref the
        # temporary references we own after the call.
        py_key = key.to_py
        py_value = value.to_py
        py_key_raw = py_key.to_unsafe
        py_value_raw = py_value.to_unsafe
        if Crython::LibPython.dict_set_item(dict, py_key_raw, py_value_raw) < 0
          if py_key.need_decref
            Crython::LibPython.decref(py_key_raw)
            py_key.need_decref = false
          end
          if py_value.need_decref
            Crython::LibPython.decref(py_value_raw)
            py_value.need_decref = false
          end
          Crython::LibPython.decref(dict)
          if Crython::LibPython.err_occurred
            Crython::LibPython.err_print
          end
          raise "Failed to insert item into dictionary"
        end

        if py_key.need_decref
          Crython::LibPython.decref(py_key_raw)
          py_key.need_decref = false
        end
        if py_value.need_decref
          Crython::LibPython.decref(py_value_raw)
          py_value.need_decref = false
        end
      end
      Crython::PyObject.new(dict, need_decref: true)
    end
  end
end
