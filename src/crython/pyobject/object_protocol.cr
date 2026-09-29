module Crython
  private module ObjectProtocol
    def callable? : Bool
      Crython.with_gil do
        LibPython.object_is_callable(@raw) != 0
      end
    end

    def has_attr?(attr : String) : Bool
      Crython.with_gil do
        LibPython.object_has_attr_string(@raw, attr.to_unsafe) != 0
      end
    end

    def attr(attr : String) : PyObject
      Crython.with_gil do
        ptr = LibPython.object_get_attr_string(@raw, attr.to_unsafe)
        if ptr.null?
          python_error = Crython.capture_python_error
          raise AttributeError.new("object", attr, python_error.try(&.to_s), python_error)
        end
        PyObject.from_owned(ptr)
      end
    end

    def attr?(attr : String) : PyObject?
      Crython.with_gil do
        ptr = LibPython.object_get_attr_string(@raw, attr.to_unsafe)
        if ptr.null?
          python_error = Crython.capture_python_error
          if python_error && python_error.type_name == "AttributeError" && python_error.name == attr
            nil
          else
            raise AttributeError.new("object", attr, python_error.try(&.to_s), python_error)
          end
        else
          PyObject.from_owned(ptr)
        end
      end
    end

    def set_attr(attr : String, obj : ObjectMethods)
      Crython.with_gil do
        result = LibPython.object_set_attr_string(@raw, attr.to_unsafe, obj.to_unsafe)
        if result < 0
          error_info = Crython.extract_python_error
          raise AttributeError.new("object", attr, error_info)
        end
      end
    end

    def del_attr(attr : String) : Bool
      Crython.with_gil do
        result = LibPython.object_del_attr_string(@raw, attr.to_unsafe)
        if result < 0
          error_info = Crython.extract_python_error
          raise AttributeError.new("object", attr, error_info)
        end
        true
      end
    end

    def <=>(other : ObjectProtocol)
      Crython.with_gil do
        if LibPython.object_cmp(@raw, other.to_unsafe, out cmp) >= 0
          cmp
        else
          error_info = Crython.extract_python_error
          raise CrythonError.new("Object comparison failed#{error_info ? " - #{error_info}" : ""}")
        end
      end
    end

    def to_unsafe
      @raw
    end
  end
end
