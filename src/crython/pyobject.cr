require "./pyobject/object_protocol"
require "./pyobject/experimental_crystalizer"
require "./cr2py/string"

module Crython
  class PyObject # FIXME: Should be struct?
    include ObjectProtocol
    include ExperimentalCrystalizer

    property need_decref : Bool

    def initialize(@raw : LibPython::PyObject, @need_decref = false)
    end

    def finalize
      if @need_decref
        LibPython.decref(@raw)
      end
    end

    macro method_missing(call)
      # Setter methods cannot have more than one argument
      {% if call.name.ends_with?("=") %}
        def {{ call.name }}(value : PyObject)
          __setattr__({{ call.name.stringify }}, value)
        end
      {% else %}
        def {{ call.name }}(*args, **kwargs)
          call({{ call.name.stringify }}, *args, **kwargs)
        end
      {% end %}
    end

    def call(call : (String | Symbol), *args, **kwargs) : PyObject
      attr = LibPython.object_get_attr_string(@raw, call.to_s.to_unsafe)
      if attr.null?
        raise "Error occurred while getting attribute '#{call}'"
      end
      if kwargs.size > 0
        if args.size == 0
          args_tuple = LibPython.tuple_new(0)
        elsif args.size == 1
          args_tuple = LibPython.build_value("(O)", *args.map(&.to_py))
        else
          args_tuple = LibPython.build_value("(" + "O" * args.size + ")", *args.map(&.to_py))
        end
        kwargs_dict = LibPython.dict_new
        kwargs.each do |k, v|
          str = k.to_s
          cstr = str.to_unsafe
          key = LibPython.unicode_from_string_and_size(cstr, str.size)
          LibPython.dict_set_item(kwargs_dict, key, v.to_py)
          LibPython.decref(key)
        end
        ret = LibPython.object_call(attr, args_tuple, kwargs_dict)
        LibPython.decref(args_tuple)
        LibPython.decref(kwargs_dict)
        LibPython.decref(attr)
        if ret.null?
          STDERR.puts "Error occurred while calling attribute '#{call}' with kwargs"
        end
      else
        if args.size > 0
          ret = LibPython.object_call_function(attr, *args.map(&.to_py), nil)
          if ret.null?
            STDERR.puts "Error occurred while calling attribute '#{call}' with args"
          end
          LibPython.decref(attr)
        else
          if PyObject.new(attr).callable?
            # PyFunction_Check is better? since callable can be a class
            # FIXME: Attr ? Func ? Class ?
            ret = LibPython.object_call_function(attr, nil)
            # User should call attr if they want to get the attribute
            # "-".to_py.attr("join")
            LibPython.decref(attr)
          else
            ret = attr
          end
        end
      end
      if LibPython.err_occurred
        LibPython.err_print
        raise "Error occurred while calling attribute '#{call}'"
      end
      PyObject.new(ret.not_nil!)
    end

    def [](*key) : PyObject
      # __getitem__
      key_tuple = LibPython.build_value("O" * key.size, *key.map(&.to_py))
      ptr = LibPython.object_get_item(@raw, key_tuple)
      LibPython.decref(key_tuple)
      if ptr.null?
        LibPython.err_print
        raise "Error occurred while getting item"
      end
      PyObject.new(ptr)
    end

    def []=(key, value) : Nil
      # __setitem__
      py_key = key.to_py
      py_value = value.to_py
      r = LibPython.object_set_item(@raw, py_key, py_value)
      LibPython.decref(py_key)
      LibPython.decref(py_value)

      if r < 0
        LibPython.err_print
        raise "Error occurred while setting item"
      end
    end

    def +(other : PyObject) : PyObject
      __add__(other)
    end

    def +(other) : PyObject
      __add__(other.to_py)
    end

    def -(other : PyObject) : PyObject
      __sub__(other)
    end

    def -(other) : PyObject
      __sub__(other.to_py)
    end

    def *(other : PyObject) : PyObject
      __mul__(other)
    end

    def *(other) : PyObject
      __mul__(other.to_py)
    end

    def /(other : PyObject) : PyObject
      __truediv__(other)
    end

    def /(other) : PyObject
      __truediv__(other.to_py)
    end

    def //(other : PyObject) : PyObject
      __floordiv__(other)
    end

    def //(other) : PyObject
      __floordiv__(other.to_py)
    end

    def %(other : PyObject) : PyObject
      __mod__(other)
    end

    def %(other) : PyObject
      __mod__(other.to_py)
    end

    def **(other : PyObject) : PyObject
      __pow__(other)
    end

    def **(other) : PyObject
      __pow__(other.to_py)
    end

    def <(other : PyObject) : PyObject
      __lt__(other)
    end

    def <(other) : PyObject
      __lt__(other.to_py)
    end

    def <=(other : PyObject) : PyObject
      __le__(other)
    end

    def <=(other) : PyObject
      __le__(other.to_py)
    end

    def >(other : PyObject) : PyObject
      __gt__(other)
    end

    def >(other) : PyObject
      __gt__(other.to_py)
    end

    def >=(other : PyObject) : PyObject
      __ge__(other)
    end

    def >=(other) : PyObject
      __ge__(other.to_py)
    end

    def ==(other : PyObject) : PyObject
      __eq__(other)
    end

    def ==(other) : PyObject
      __eq__(other.to_py)
    end

    def !=(other : PyObject) : PyObject
      __ne__(other)
    end

    def !=(other) : PyObject
      __ne__(other.to_py)
    end

    def to_s(io) : Nil
      s = LibPython.object_str(@raw)
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
