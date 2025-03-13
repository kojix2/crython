module Crython
  private module ExperimentalCrystalizer # Experimental
    def to_cr
      type_obj = LibPython.object_type(@raw)
      if type_obj.null?
        raise CrythonError.new("Failed to get type object")
      end

      begin
        type_str = LibPython.object_str(type_obj)
        if type_str.null?
          raise CrythonError.new("Failed to get type name")
        end

        begin
          type_name = String.new(LibPython.unicode_as_utf8(type_str))
        ensure
          LibPython.decref(type_str)
        end

        case type_name
        when "<class 'int'>"
          # Check for overflow
          value = LibPython.long_as_long(@raw)
          if LibPython.err_occurred
            error_info = Crython.extract_python_error
            LibPython.err_clear
            raise ValueError.new("Integer overflow: #{error_info}")
          end
          value
        when "<class 'float'>"
          # Check for special values
          value = LibPython.float_as_double(@raw)
          if LibPython.err_occurred
            error_info = Crython.extract_python_error
            LibPython.err_clear
            raise ValueError.new("Float conversion error: #{error_info}")
          end
          value
        when "<class 'str'>"
          ptr = LibPython.unicode_as_utf8(@raw)
          if ptr.null?
            raise ValueError.new("Failed to convert Python string to UTF-8")
          end
          String.new(ptr)
        when "<class 'bool'>"
          Bool.new(self)
        when "<class 'NoneType'>"
          nil
        else
          raise TypeError.new(type_name, "Crystal type", "Unsupported Python type")
        end
      ensure
        LibPython.decref(type_obj) unless type_obj.nil?
      end
    end

    # Helper method to get Python object type name
    def get_type_name : String
      type_obj = LibPython.object_type(@raw)
      if type_obj.null?
        return "unknown"
      end

      type_str = LibPython.object_str(type_obj)
      if type_str.null?
        LibPython.decref(type_obj)
        return "unknown"
      end

      type_name = String.new(LibPython.unicode_as_utf8(type_str))
      LibPython.decref(type_str)
      LibPython.decref(type_obj)

      type_name
    end
  end
end
