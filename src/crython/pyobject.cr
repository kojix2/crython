require "./pyobject/object_protocol"
require "./cr2py/string"

module Crython
  class PyObject
    include ObjectProtocol

    property need_decref : Bool

    # @id : Int32 = Random.rand(1000000) # Unique identifier for logging
    @session_id : UInt64 = Crython.session_id

    def initialize(@raw : LibPython::PyObject, @need_decref = false)
      ##############################################################
      # GARBAGE COLLECTION DEBUGGING CODE
      ##############################################################
      # @session_id = Crython.session_id
      # value_str = LibPython.object_str(@raw)
      # value_ptr = LibPython.unicode_as_utf8(value_str)
      # type_ptr = LibPython.object_get_attr_string(@raw, "__class__".to_unsafe)
      # type_name_ptr = LibPython.object_get_attr_string(type_ptr, "__name__".to_unsafe)
      # type_name = LibPython.unicode_as_utf8(type_name_ptr)
      # puts "Initialized PyObject with ID: #{@id}, Python Type: #{String.new(type_name)}, Value: #{String.new(value_ptr)}"
      # LibPython.decref(type_ptr)
      # LibPython.decref(type_name_ptr)
      # LibPython.decref(value_str)
      ###############################################################
    end

    def finalize
      if @need_decref && Crython.active_session?(@session_id)
        # puts "Finalizing PyObject with ID: #{@id} and session_id: #{@session_id}"
        LibPython.decref(@raw)
        # puts "Finalized PyObject with ID: #{@id} and session_id: #{@session_id}"
      end
    end

    macro method_missing(call)
      {% if call.name.ends_with?("=") %}
        def {{ call.name }}(value)
          __setattr__({{ call.name.stringify }}, value.to_py)
        end
      {% else %}
        def {{ call.name }}(*args, **kwargs)
          call({{ call.name.stringify }}, *args, **kwargs)
        end
      {% end %}
    end

    def call(call : (String | Symbol), *args, **kwargs) : PyObject
      # Get object type for better error messages
      type_ptr = LibPython.object_get_attr_string(@raw, "__class__".to_unsafe)
      type_name_ptr = LibPython.object_get_attr_string(type_ptr, "__name__".to_unsafe)
      type_name = String.new(LibPython.unicode_as_utf8(type_name_ptr))
      LibPython.decref(type_name_ptr)
      LibPython.decref(type_ptr)

      # Get attribute
      attr = LibPython.object_get_attr_string(@raw, call.to_s.to_unsafe)
      if attr.null?
        error_info = Crython.extract_python_error
        raise AttributeError.new(type_name, call.to_s, error_info)
      end

      # Call with kwargs
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
          # unicode_from_string_and_size and v.to_py both return new
          # references. PyDict_SetItem does not steal references; it
          # increments the reference counts internally. We must decref the
          # temporaries we own after the call.
          value_py = v.to_py
          LibPython.dict_set_item(kwargs_dict, key, value_py.to_unsafe)
          LibPython.decref(key)
          LibPython.decref(value_py.to_unsafe)
          value_py.need_decref = false
        end
        ret = LibPython.object_call(attr, args_tuple, kwargs_dict)
        LibPython.decref(args_tuple)
        LibPython.decref(kwargs_dict)
        LibPython.decref(attr)
        if ret.null?
          error_info = Crython.extract_python_error
          raise CallError.new(call.to_s, "Error with kwargs - #{error_info}")
        end
      else
        # Call with args only
        if args.size > 0
          ret = LibPython.object_call_function(attr, *args.map(&.to_py), nil)
          if ret.null?
            error_info = Crython.extract_python_error
            LibPython.decref(attr)
            raise CallError.new(call.to_s, "Error with args - #{error_info}")
          end
          LibPython.decref(attr)
        else
          # No args - either call as function or return attribute
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

      # Check for errors
      if LibPython.err_occurred
        error_info = Crython.extract_python_error
        LibPython.err_print
        raise CallError.new(call.to_s, error_info)
      end

      PyObject.new(ret.not_nil!)
    end

    def [](*key) : PyObject
      # __getitem__
      key_tuple = LibPython.build_value("O" * key.size, *key.map(&.to_py))
      ptr = LibPython.object_get_item(@raw, key_tuple)
      LibPython.decref(key_tuple)
      if ptr.null?
        error_info = Crython.extract_python_error
        LibPython.err_print
        raise ItemError.new(error_info)
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
        error_info = Crython.extract_python_error
        LibPython.err_print
        raise ItemError.new(error_info)
      end
    end

    {% for op, method in {
                           "+"  => "__add__",
                           "-"  => "__sub__",
                           "*"  => "__mul__",
                           "/"  => "__truediv__",
                           "//" => "__floordiv__",
                           "%"  => "__mod__",
                           "**" => "__pow__",
                           "<"  => "__lt__",
                           "<=" => "__le__",
                           ">"  => "__gt__",
                           ">=" => "__ge__",
                           "==" => "__eq__",
                           "!=" => "__ne__",
                         } %}

      def {{op.id}}(other : PyObject) : PyObject
        {{method.id}}(other)
      end

      def {{op.id}}(other) : PyObject
        {{method.id}}(other.to_py)
      end

    {% end %}

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
