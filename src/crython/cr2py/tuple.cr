struct Tuple
  def to_py : Crython::PyObject
    tuple = Crython::LibPython.tuple_new(self.size)
    self.each_with_index do |item, index|
      # PyTuple_SetItem steals a reference.
      # If item.to_py returns a borrowed wrapper (need_decref = false),
      # incref before insertion so ownership transfer is safe.
      py_item = item.to_py
      py_item_raw = py_item.to_unsafe
      if py_item.need_decref
        py_item.need_decref = false
      else
        Crython::LibPython.incref(py_item_raw)
      end

      if Crython::LibPython.tuple_set_item(tuple, index, py_item_raw) < 0
        Crython::LibPython.decref(py_item_raw)
        Crython::LibPython.decref(tuple)
        if Crython::LibPython.err_occurred
          Crython::LibPython.err_print
        end
        raise "Failed to insert item into tuple"
      end
    end
    Crython::PyObject.new(tuple, need_decref: true)
  end
end
