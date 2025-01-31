module Crython
  private module ObjectProtocol
    def none?
      LibCrython.none?(@raw) != 0
    end

    def callable? : Bool
      LibPython.object_callable?(@raw) != 0
    end

    def has_attr?(attr : String) : Bool
      LibPython.object_has_attr_string(@raw, attr.to_unsafe) != 0
    end

    def get_attr(attr : String) : PyObject
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

  struct PyObject
    include ObjectProtocol

    def initialize(@raw : LibPython::PyObject)
    end

    macro method_missing(call)
      def {{ call.name }}(
        {% for arg in call.args %}
        {{arg}},
      {% end %}
      {% if call.named_args %}
        {% for narg in call.named_args %}
          {{narg.name}},
        {% end %}
      {% end %}
    )
        attr = LibPython.object_get_attr_string(@raw, {{ call.name.stringify }}.to_unsafe)
        {% if call.named_args %}
          {% if call.args.size == 0 %}
            args_tuple = LibPython.tuple_new(0)
          {% elsif call.args.size == 1 %}
            args_tuple = LibPython.build_value("(O)", {{ call.args.splat }})
          {% elsif call.args.size > 1 %}
            args_tuple = LibPython.build_value("O" * {{ call.args.size }}, {{ call.args.splat }})
          {% end %}
          kwargs_dict = LibPython.dict_new
          {% for narg in call.named_args %}
            str = {{ narg.name.stringify }}
            cstr = str.to_unsafe
            k = LibPython.unicode_from_string_and_size(cstr, str.size)
            LibPython.dict_set_item(kwargs_dict, k, {{ narg.name }})
          {% end %}
          ret = LibPython.object_call(attr, args_tuple, kwargs_dict)
        {% else %}
          {% if call.args.size > 0 %}
            ret = LibPython.object_call_function(attr, {{ call.args.splat }}, nil)
          {% else %}
            ret = LibPython.object_call_function(attr, nil)
          {% end %}
        {% end %}
        PyObject.new(ret)
      end
    end

    def [](key) : PyObject
      __getitem__(key.to_py)
    end

    def +(other : PyObject) : PyObject
      __add__(other)
    end

    def -(other : PyObject) : PyObject
      __sub__(other)
    end

    def *(other : PyObject) : PyObject
      __mul__(other)
    end

    def /(other : PyObject) : PyObject
      __truediv__(other)
    end

    def //(other : PyObject) : PyObject
      __floordiv__(other)
    end

    def **(other : PyObject) : PyObject
      __pow__(other)
    end

    def to_s(io) : Nil
      s = LibPython.object_string(@raw)
      ptr = LibPython.unicode_as_utf8(s)
      io.print String.new(ptr)
    end

    def inspect(io) : Nil
      s = LibPython.object_repr(@raw)
      ptr = LibPython.unicode_as_utf8(s)
      io.print String.new(ptr)
    end
  end
end
