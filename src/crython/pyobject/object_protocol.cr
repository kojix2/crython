module Crython
  private module ObjectProtocol
    def callable? : Bool
      LibPython.object_is_callable(@raw) != 0
    end

    def has_attr?(attr : String) : Bool
      LibPython.object_has_attr_string(@raw, attr.to_unsafe) != 0
    end

    def attr(attr : String) : PyObject
      PyObject.new(LibPython.object_get_attr_string(@raw, attr.to_unsafe))
    end

    def set_attr(attr : String, obj : ObjectMethods)
      if LibPython.object_set_attr_string(@raw, attr.to_unsafe, obj.to_unsafe) == 0
        # TODO: handle exception
      end
    end

    def del_attr(attr : String) : Bool
      LibPython.object_del_attr_string(@raw, attr.to_unsafe) != 0
    end

    def <=>(other : ObjectProtocol)
      if LibPython.object_cmp(@raw, other.to_unsafe, out cmp) >= 0
        cmp
      else
        # TODO: handle exception
      end
    end

    def to_unsafe
      @raw
    end
  end
end
