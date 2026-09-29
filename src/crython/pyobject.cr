require "./pyobject/object_protocol"
require "./cr2py/string"

module Crython
  class PyObject
    include ObjectProtocol

    # A wrapper always owns exactly one strong Python reference.
    getter raw : LibPython::PyObject

    private def initialize(@raw : LibPython::PyObject)
    end

    # Adopt a new reference returned by a CPython API.
    def self.from_owned(raw : LibPython::PyObject) : PyObject
      if raw.null?
        raise CrythonError.new("cannot wrap a null Python object")
      end
      new(raw)
    end

    # Promote a borrowed reference before its owner can be released.
    def self.from_borrowed(raw : LibPython::PyObject) : PyObject
      if raw.null?
        raise CrythonError.new("cannot wrap a null Python object")
      end
      Crython.with_gil { LibPython.incref(raw) }
      new(raw)
    end

    def finalize
      if Crython.initialized?
        state = LibPython.gil_state_ensure
        begin
          LibPython.decref(@raw)
        ensure
          LibPython.gil_state_release(state)
        end
      end
    end

    # Convenience syntax for simple Python method calls.
    # For uppercase attribute names or other complex call sites, prefer
    # `obj.call("Name", ...)` because Crystal method syntax is stricter
    # than Python attribute syntax.
    macro method_missing(call)
      {% if call.name.ends_with?("=") %}
        def {{ call.name }}(value)
          __setattr__({{ call.name.stringify }}, value.to_py)
        end
      {% else %}
        {% if call.name.stringify =~ /^[A-Z]/ %}
          {% raise "Uppercase Python attributes must use call(\"Name\", ...). Example: obj.call(\"Counter\", args...)" %}
        {% end %}
        def {{ call.name }}(*args, **kwargs)
          call({{ call.name.stringify }}, *args, **kwargs)
        end
      {% end %}
    end

    # Reliable public API for Python attribute lookup and invocation.
    # Use this when the Python attribute name is not a natural Crystal
    # method name, such as class constructors like `Counter`.
    def call(call : (String | Symbol), *args, **kwargs) : PyObject
      Crython.with_gil do
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
            value_raw = Pointer(Void).null.as(LibPython::PyObject)
            if arg.is_a?(PyObject)
              value_raw = arg.as(PyObject).to_unsafe
              LibPython.incref(value_raw)
            else
              value_py = arg.to_py
              value_raw = value_py.to_unsafe

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
            value_py = nil
            value_raw = Pointer(Void).null.as(LibPython::PyObject)
            if v.is_a?(PyObject)
              value_raw = v.as(PyObject).to_unsafe
            else
              value_py = v.to_py
              value_raw = value_py.to_unsafe
            end
            if LibPython.dict_set_item(kwargs_dict, key, value_raw) < 0
              LibPython.decref(key)
              LibPython.decref(kwargs_dict)
              LibPython.decref(args_tuple)
              LibPython.decref(attr)
              error_info = Crython.extract_python_error
              raise CallError.new(call.to_s, "Error building kwargs dict - #{error_info}")
            end
            LibPython.decref(key)
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
              value_raw = Pointer(Void).null.as(LibPython::PyObject)
              if arg.is_a?(PyObject)
                value_raw = arg.as(PyObject).to_unsafe
                LibPython.incref(value_raw)
              else
                value_py = arg.to_py
                value_raw = value_py.to_unsafe

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
            if LibPython.object_is_callable(attr) != 0
              # Use PyObject_Call with an explicit empty tuple to avoid
              # varargs ABI issues from PyObject_CallFunctionObjArgs.
              empty_args = LibPython.tuple_new(0)
              ret = LibPython.object_call(attr, empty_args, Pointer(Void).null.as(LibPython::PyObject))
              LibPython.decref(empty_args)
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
          raise CallError.new(call.to_s, error_info)
        end

        PyObject.from_owned(ret.not_nil!)
      end
    end

    def call?(call : (String | Symbol), *args, **kwargs) : PyObject?
      call(call, *args, **kwargs)
    rescue AttributeError | CallError
      nil
    end

    def [](*key) : PyObject
      Crython.with_gil do
        # __getitem__
        if key.size <= 1
          py_key = nil
          py_key_raw = Pointer(Void).null.as(LibPython::PyObject)
          if key.size == 1 && key[0].is_a?(PyObject)
            py_key_raw = key[0].as(PyObject).to_unsafe
          else
            py_key = key.size == 1 ? key[0].to_py : nil.to_py
            py_key_raw = py_key.not_nil!.to_unsafe
          end

          ptr = LibPython.object_get_item(@raw, py_key_raw)
        else
          key_tuple = LibPython.tuple_new(key.size)
          key.each_with_index do |item, index|
            py_item_raw = Pointer(Void).null.as(LibPython::PyObject)
            if item.is_a?(PyObject)
              py_item_raw = item.as(PyObject).to_unsafe
              LibPython.incref(py_item_raw)
            else
              py_item = item.to_py
              py_item_raw = py_item.to_unsafe

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
          raise ItemError.new(error_info)
        end
        PyObject.from_owned(ptr)
      end
    end

    def []=(key, value) : Nil
      Crython.with_gil do
        # __setitem__
        py_key = nil
        py_value = nil
        py_key_raw = Pointer(Void).null.as(LibPython::PyObject)
        py_value_raw = Pointer(Void).null.as(LibPython::PyObject)

        if key.is_a?(PyObject)
          py_key_raw = key.as(PyObject).to_unsafe
        else
          py_key = key.to_py
          py_key_raw = py_key.not_nil!.to_unsafe
        end

        if value.is_a?(PyObject)
          py_value_raw = value.as(PyObject).to_unsafe
        else
          py_value = value.to_py
          py_value_raw = py_value.not_nil!.to_unsafe
        end

        r = LibPython.object_set_item(@raw, py_key_raw, py_value_raw)

        if r < 0
          error_info = Crython.extract_python_error
          raise ItemError.new(error_info)
        end
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
      Crython.with_gil do
        s = LibPython.object_str(@raw)
        begin
          ptr = LibPython.unicode_as_utf8(s)
          io.print String.new(ptr)
        ensure
          LibPython.decref(s)
        end
      end
    end

    def inspect(io) : Nil
      Crython.with_gil do
        s = LibPython.object_repr(@raw)
        begin
          ptr = LibPython.unicode_as_utf8(s)
          io.print String.new(ptr)
        ensure
          LibPython.decref(s)
        end
      end
    end

    def to_py : PyObject
      self
    end
  end
end
