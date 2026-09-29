require "./pyobject/object_protocol"
require "./cr2py/string"

module Crython
  class PyObject
    include ObjectProtocol

    # A wrapper always owns exactly one strong Python reference.
    getter raw : LibPython::PyObject

    private def initialize(@raw : LibPython::PyObject, @release_node : Void*)
    end

    # Adopt a new reference returned by a CPython API.
    def self.from_owned(raw : LibPython::PyObject) : PyObject
      if raw.null?
        raise CrythonError.new("cannot wrap a null Python object")
      end
      node = LibCrythonRuntime.release_node_new(raw)
      if node.null?
        Crython.with_gil { LibPython.decref(raw) }
        raise CrythonError.new("cannot allocate Python reference release node")
      end
      new(raw, node)
    end

    # Promote a borrowed reference before its owner can be released.
    def self.from_borrowed(raw : LibPython::PyObject) : PyObject
      if raw.null?
        raise CrythonError.new("cannot wrap a null Python object")
      end
      Crython.with_gil { LibPython.incref(raw) }
      from_owned(raw)
    end

    def finalize
      LibCrythonRuntime.release_node_enqueue(@release_node)
    end

    # Convenience syntax for simple Python method calls.
    # For uppercase attribute names or other complex call sites, prefer
    # `obj.call("Name", ...)` because Crystal method syntax is stricter
    # than Python attribute syntax.
    macro method_missing(call)
      {% if call.name.ends_with?("=") %}
        def {{ call.name }}(value)
          __setattr__({{ call.name.stringify }}[0...-1], value.to_py)
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
        attr = LibPython.object_get_attr_string(@raw, call.to_s.to_unsafe)
        if attr.null?
          error_info = Crython.extract_python_error
          raise AttributeError.new("object", call.to_s, error_info)
        end

        begin
          # Keep the historical zero-argument behaviour: a non-callable
          # attribute is returned rather than invoked.
          result = if args.empty? && kwargs.empty? && LibPython.object_is_callable(attr) == 0
                     attr
                   else
                     invoke_raw(attr, call.to_s, args, kwargs)
                   end
          attr = Pointer(Void).null.as(LibPython::PyObject) if result == attr
          PyObject.from_owned(result)
        ensure
          LibPython.decref(attr) unless attr.null?
        end
      end
    end

    # Invoke this object itself when it is callable.
    def invoke(*args, **kwargs) : PyObject
      Crython.with_gil do
        PyObject.from_owned(invoke_raw(@raw, "callable", args, kwargs))
      end
    end

    def call?(call : (String | Symbol), *args, **kwargs) : PyObject?
      call(call, *args, **kwargs)
    rescue AttributeError | CallError
      nil
    end

    private def invoke_raw(callable : LibPython::PyObject, name : String, args, kwargs) : LibPython::PyObject
      args_tuple = build_args_tuple(args, name)
      kwargs_dict = build_kwargs_dict(kwargs, name)
      begin
        result = LibPython.object_call(callable, args_tuple, kwargs_dict)
        if result.null?
          error_info = Crython.extract_python_error
          raise CallError.new(name, error_info)
        end
        result
      ensure
        LibPython.decref(args_tuple)
        LibPython.decref(kwargs_dict) unless kwargs_dict.null?
      end
    end

    private def build_args_tuple(args, name : String) : LibPython::PyObject
      tuple = LibPython.tuple_new(args.size)
      if tuple.null?
        error_info = Crython.extract_python_error
        raise CallError.new(name, "Error building args tuple - #{error_info}")
      end

      complete = false
      begin
        args.each_with_index do |arg, index|
          value_py = arg.is_a?(PyObject) ? arg.as(PyObject) : arg.to_py
          value_raw = value_py.to_unsafe
          LibPython.incref(value_raw)

          # PyTuple_SetItem steals this reference even when it fails.
          if LibPython.tuple_set_item(tuple, index, value_raw) < 0
            error_info = Crython.extract_python_error
            raise CallError.new(name, "Error building args tuple - #{error_info}")
          end
        end
        complete = true
        tuple
      ensure
        LibPython.decref(tuple) unless complete
      end
    end

    private def build_kwargs_dict(kwargs, name : String) : LibPython::PyObject
      return Pointer(Void).null.as(LibPython::PyObject) if kwargs.empty?

      dict = LibPython.dict_new
      if dict.null?
        error_info = Crython.extract_python_error
        raise CallError.new(name, "Error building kwargs dict - #{error_info}")
      end

      complete = false
      begin
        kwargs.each do |key_name, value|
          key_string = key_name.to_s
          key = LibPython.unicode_from_string_and_size(key_string.to_unsafe, key_string.bytesize)
          if key.null?
            error_info = Crython.extract_python_error
            raise CallError.new(name, "Error building kwargs dict - #{error_info}")
          end

          begin
            value_py = value.is_a?(PyObject) ? value.as(PyObject) : value.to_py
            if LibPython.dict_set_item(dict, key, value_py.to_unsafe) < 0
              error_info = Crython.extract_python_error
              raise CallError.new(name, "Error building kwargs dict - #{error_info}")
            end
          ensure
            LibPython.decref(key)
          end
        end
        complete = true
        dict
      ensure
        LibPython.decref(dict) unless complete
      end
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
              error_info = Crython.extract_python_error
              LibPython.decref(key_tuple)
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
          bytesize = uninitialized LibC::SSizeT
          ptr = LibPython.unicode_as_utf8_and_size(s, pointerof(bytesize))
          raise ValueError.new("Failed to convert Python string to UTF-8") if ptr.null?
          io.print String.new(ptr, bytesize.to_i)
        ensure
          LibPython.decref(s)
        end
      end
    end

    def inspect(io) : Nil
      Crython.with_gil do
        s = LibPython.object_repr(@raw)
        begin
          bytesize = uninitialized LibC::SSizeT
          ptr = LibPython.unicode_as_utf8_and_size(s, pointerof(bytesize))
          raise ValueError.new("Failed to convert Python string to UTF-8") if ptr.null?
          io.print String.new(ptr, bytesize.to_i)
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
