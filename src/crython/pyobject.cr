require "./pyobject/object_protocol"
require "./cr2py/string"

module Crython
  class PyObject
    include ObjectProtocol

    # Ownership rules
    # - `need_decref = true` means this wrapper owns one Python reference.
    # - `need_decref = false` means borrowed/non-owning wrapper.
    # - When passing values to a stealing API (e.g. PyTuple_SetItem,
    #   PyList_SetItem), transfer ownership only if we own the ref;
    #   otherwise incref before passing.
    # - When passing values to a non-stealing API (e.g. PyDict_SetItem),
    #   decref temporary values only if this wrapper owns them.
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
        args_tuple = LibPython.tuple_new(args.size)
        args.each_with_index do |arg, index|
          value_py = arg.to_py
          value_raw = value_py.to_unsafe

          if value_py.need_decref
            value_py.need_decref = false
          else
            LibPython.incref(value_raw)
          end

          if LibPython.tuple_set_item(args_tuple, index, value_raw) < 0
            LibPython.decref(value_raw)
            LibPython.decref(args_tuple)
            LibPython.decref(attr)
            error_info = Crython.extract_python_error
            raise CallError.new(call.to_s, "Error building args tuple - #{error_info}")
          end
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
          value_raw = value_py.to_unsafe
          if LibPython.dict_set_item(kwargs_dict, key, value_py.to_unsafe) < 0
            LibPython.decref(key)
            if value_py.need_decref
              LibPython.decref(value_raw)
              value_py.need_decref = false
            end
            LibPython.decref(kwargs_dict)
            LibPython.decref(args_tuple)
            LibPython.decref(attr)
            error_info = Crython.extract_python_error
            raise CallError.new(call.to_s, "Error building kwargs dict - #{error_info}")
          end
          LibPython.decref(key)
          if value_py.need_decref
            LibPython.decref(value_raw)
            value_py.need_decref = false
          end
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
          args_tuple = LibPython.tuple_new(args.size)
          args.each_with_index do |arg, index|
            value_py = arg.to_py
            value_raw = value_py.to_unsafe

            if value_py.need_decref
              value_py.need_decref = false
            else
              LibPython.incref(value_raw)
            end

            if LibPython.tuple_set_item(args_tuple, index, value_raw) < 0
              LibPython.decref(value_raw)
              LibPython.decref(args_tuple)
              LibPython.decref(attr)
              error_info = Crython.extract_python_error
              raise CallError.new(call.to_s, "Error building args tuple - #{error_info}")
            end
          end

          ret = LibPython.object_call(attr, args_tuple, Pointer(Void).null.as(LibPython::PyObject))
          LibPython.decref(args_tuple)
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
      if key.size <= 1
        py_key = key.size == 1 ? key[0].to_py : nil.to_py
        py_key_raw = py_key.to_unsafe

        ptr = LibPython.object_get_item(@raw, py_key_raw)

        if py_key.need_decref
          LibPython.decref(py_key_raw)
          py_key.need_decref = false
        end
      else
        key_tuple = LibPython.tuple_new(key.size)
        key.each_with_index do |item, index|
          py_item = item.to_py
          py_item_raw = py_item.to_unsafe

          if py_item.need_decref
            py_item.need_decref = false
          else
            LibPython.incref(py_item_raw)
          end

          if LibPython.tuple_set_item(key_tuple, index, py_item_raw) < 0
            LibPython.decref(py_item_raw)
            LibPython.decref(key_tuple)
            error_info = Crython.extract_python_error
            raise ItemError.new("Error building key tuple - #{error_info}")
          end
        end

        ptr = LibPython.object_get_item(@raw, key_tuple)
        LibPython.decref(key_tuple)
      end

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
      py_key_raw = py_key.to_unsafe
      py_value_raw = py_value.to_unsafe

      r = LibPython.object_set_item(@raw, py_key_raw, py_value_raw)

      if py_key.need_decref
        LibPython.decref(py_key_raw)
        py_key.need_decref = false
      end
      if py_value.need_decref
        LibPython.decref(py_value_raw)
        py_value.need_decref = false
      end

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
      begin
        ptr = LibPython.unicode_as_utf8(s)
        io.print String.new(ptr)
      ensure
        LibPython.decref(s)
      end
    end

    def inspect(io) : Nil
      s = LibPython.object_repr(@raw)
      begin
        ptr = LibPython.unicode_as_utf8(s)
        io.print String.new(ptr)
      ensure
        LibPython.decref(s)
      end
    end

    def to_py : PyObject
      self
    end
  end
end
