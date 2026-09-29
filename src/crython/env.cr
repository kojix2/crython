module Crython
  PY_SINGLE_INPUT = 256
  PY_FILE_INPUT = 257
  PY_EVAL_INPUT = 258

  def self.debug_enabled? : Bool
    ENV["CRYTHON_DEBUG"]? == "1"
  end

  class InitializationError < CrythonError
  end

  @@initialized = false
  @@owner_thread : Thread? = nil

  # Crython currently supports only the OS thread that initialized CPython.
  def self.with_gil(&)
    ensure_initialized!
    state = LibPython.gil_state_ensure
    begin
      yield
    ensure
      LibPython.gil_state_release(state)
    end
  end

  def self.debug_log(message : String) : Nil
    STDERR.puts("[crython][debug] #{message}") if debug_enabled?
  end

  # Initialize CPython once for this process. Attaching to an interpreter
  # initialized by another library is deliberately unsupported.
  def self.init : Nil
    return if @@initialized

    if LibPython.is_initialized != 0
      raise InitializationError.new("Python was initialized outside Crython; attaching to it is unsupported")
    end

    LibPython.init
    if LibPython.is_initialized == 0
      raise InitializationError.new("Py_Initialize did not initialize Python")
    end

    @@owner_thread = Thread.current
    @@initialized = true
    debug_log("init:python runtime initialized")
  end

  # Whether the Crython-managed CPython runtime is available.
  def self.initialized? : Bool
    @@initialized
  end

  # Python environment information (cached)
  def self.python_version : String
    String.new(LibPython.get_version)
  end

  def self.python_build_info : String
    String.new(LibPython.get_build_info)
  end

  def self.python_compiler : String
    String.new(LibPython.get_compiler)
  end

  def self.eval_preview(code : String) : String
    preview = code.size > 120 ? "#{code[0, 120]}..." : code
    preview.gsub('\n', "\\n").gsub('\r', "\\r")
  end

  # Get a new reference to Python None without using varargs APIs.
  def self.none_newref : LibPython::PyObject
    with_gil do
      builtins = LibPython.import("builtins")
      if builtins.null?
        error_info = extract_python_error
        raise ImportError.new("builtins", error_info)
      end

      begin
        none_obj = LibPython.object_get_attr_string(builtins, "None".to_unsafe)
        if none_obj.null?
          error_info = extract_python_error
          raise AttributeError.new("builtins", "None", error_info)
        end
        none_obj
      ensure
        LibPython.decref(builtins)
      end
    end
  end

  # Execute Python statements in the shared __main__ namespace.
  def self.exec(code : String) : Nil
    debug_log("exec:start bytes=#{code.bytesize} preview=#{eval_preview(code)}")
    with_gil do
      result = execute_code(code, PY_FILE_INPUT, "<crython-exec>", "executing Python code")
      LibPython.decref(result)
    end
    debug_log("exec:done")
  end

  # Evaluate a Python expression in the shared __main__ namespace.
  def self.eval(code : String) : PyObject
    debug_log("eval:start bytes=#{code.bytesize} preview=#{eval_preview(code)}")
    result = with_gil do
      execute_code(code, PY_EVAL_INPUT, "<crython-eval>", "evaluating Python expression", " (Use Crython.exec for statements)")
    end
    debug_log("eval:done")
    PyObject.from_owned(result)
  end

  private def self.execute_code(code : String, input_mode : Int32, filename : String, operation : String, syntax_hint : String? = nil) : LibPython::PyObject
    code_obj = LibPython.compile_string(code.to_unsafe, filename.to_unsafe, input_mode)
    if code_obj.null?
      error_info = extract_python_error
      message = "Error #{operation}#{error_info ? " - #{error_info}" : ""}"
      message += syntax_hint.not_nil! if syntax_hint && error_info && error_info.includes?("SyntaxError")
      raise CrythonError.new(message)
    end

    begin
      main_mod = LibPython.import("__main__")
      if main_mod.null?
        raise ImportError.new("__main__", extract_python_error)
      end

      begin
        main_dict = LibPython.object_get_attr_string(main_mod, "__dict__".to_unsafe)
        if main_dict.null?
          raise AttributeError.new("__main__", "__dict__", extract_python_error)
        end

        begin
          value = LibPython.eval_eval_code(code_obj, main_dict, main_dict)
          if value.null?
            raise CrythonError.new("Error #{operation}#{(error_info = extract_python_error) ? " - #{error_info}" : ""}")
          end
          value
        ensure
          LibPython.decref(main_dict)
        end
      ensure
        LibPython.decref(main_mod)
      end
    ensure
      LibPython.decref(code_obj)
    end
  end

  private def self.ensure_initialized! : Nil
    unless @@initialized
      raise InitializationError.new("Crython.init must be called before using Python")
    end
    if @@owner_thread != Thread.current
      raise InitializationError.new("Crython may only be used from the thread that called Crython.init")
    end
  end
end
