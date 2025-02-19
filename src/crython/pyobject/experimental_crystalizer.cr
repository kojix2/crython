module Crython
  private module ExperimentalCrystalizer # Experimental
    def to_cr
      type_obj = LibPython.object_type(@raw)
      if type_obj.null?
        raise "Failed to get type object"
      end
      begin
        type_str = LibPython.object_str(type_obj)
        if type_str.null?
          raise "Failed to get type name"
        end
        begin
          type_name = String.new(LibPython.unicode_as_utf8(type_str))
        ensure
          LibPython.decref(type_str)
        end
        case type_name
        when "<class 'int'>"
          LibPython.long_as_long(@raw)
        when "<class 'float'>"
          LibPython.float_as_double(@raw)
        when "<class 'str'>"
          ptr = LibPython.unicode_as_utf8(@raw)
          String.new(ptr)
        when "<class 'bool'>"
          Bool.new(self)
        when "<class 'NoneType'>"
          nil 
        else
          raise "Unsupported type: #{type_name}"
        end
      ensure
        LibPython.decref(type_obj) unless type_obj.nil?
      end
    end
  end
end
