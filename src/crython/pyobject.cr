require "./pyobject/object_protocol"

module Crython
  struct PyObject
    include ObjectProtocol

    def initialize(@raw : LibPython::PyObject)
    end

    # macro method_missing(call)
    #   def {{ call.name }}(
    #     {% for arg in call.args %}
    #     {{arg}},
    #   {% end %}
    #   {% if call.named_args %}
    #     {% for narg in call.named_args %}
    #       {{narg.name}},
    #     {% end %}
    #   {% end %}
    # )
    #     attr = LibPython.object_get_attr_string(@raw, {{ call.name.stringify }}.to_unsafe)
    #     {% if call.named_args %}
    #       {% if call.args.size == 0 %}
    #         args_tuple = LibPython.tuple_new(0)
    #       {% elsif call.args.size == 1 %}
    #         args_tuple = LibPython.build_value("(O)", {{ call.args.splat }})
    #       {% elsif call.args.size > 1 %}
    #         args_tuple = LibPython.build_value("O" * {{ call.args.size }}, {{ call.args.splat }})
    #       {% end %}
    #       kwargs_dict = LibPython.dict_new
    #       {% for narg in call.named_args %}
    #         str = {{ narg.name.stringify }}
    #         cstr = str.to_unsafe
    #         k = LibPython.unicode_from_string_and_size(cstr, str.size)
    #         LibPython.dict_set_item(kwargs_dict, k, {{ narg.name }})
    #       {% end %}
    #       ret = LibPython.object_call(attr, args_tuple, kwargs_dict)
    #     {% else %}
    #       {% if call.args.size > 0 %}
    #         ret = LibPython.object_call_function(attr, {{ call.args.splat }}, nil)
    #       {% else %}
    #         ret = LibPython.object_call_function(attr, nil)
    #       {% end %}
    #     {% end %}
    #     PyObject.new(ret)
    #   end
    # end

    macro method_missing(call)
      def {{ call.name }}(*args, **kwargs)
        call({{ call.name.stringify }}, *args, **kwargs)
      end
    end

    def call(call : (String | Symbol), *args, **kwargs) : PyObject
      attr = LibPython.object_get_attr_string(@raw, call.to_s.to_unsafe)
      if kwargs.size > 0
        if args.size == 0
          args_tuple = LibPython.tuple_new(0)
        elsif args.size == 1
          args_tuple = LibPython.build_value("(O)", *args.map(&.to_py))
        else
          args_tuple = LibPython.build_value("O" * args.size, *args.map(&.to_py))
        end
        kwargs_dict = LibPython.dict_new
        kwargs.each do |k, v|
          str = k.to_s
          cstr = str.to_unsafe
          key = LibPython.unicode_from_string_and_size(cstr, str.size)
          LibPython.dict_set_item(kwargs_dict, key, v.to_py)
        end
        ret = LibPython.object_call(attr, args_tuple, kwargs_dict)
      else
        if args.size > 0
          ret = LibPython.object_call_function(attr, *args.map(&.to_py), nil)
        else
          ret = LibPython.object_call_function(attr, nil)
        end
      end
      PyObject.new(ret)
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

    def %(other : PyObject) : PyObject
      __mod__(other)
    end

    def **(other : PyObject) : PyObject
      __pow__(other)
    end

    def <(other : PyObject) : Bool
      __lt__(other)
    end

    def <=(other : PyObject) : Bool
      __le__(other)
    end

    def >(other : PyObject) : Bool
      __gt__(other)
    end

    def >=(other : PyObject) : Bool
      __ge__(other)
    end

    def ==(other : PyObject) : Bool
      __eq__(other)
    end

    def !=(other : PyObject) : Bool
      __ne__(other)
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

    def to_py : PyObject
      self
    end
  end
end
