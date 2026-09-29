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

  # Execute Python statements with error handling.
  def self.exec(code : String) : Nil
    debug_log("exec:start bytes=#{code.bytesize} preview=#{eval_preview(code)}")
    result = with_gil do
      rc = LibPython.run_simple_string(code.to_unsafe)
      py_err = !LibPython.err_occurred.null?
      debug_log("exec:done rc=#{rc} py_err=#{py_err}")
      {rc, py_err}
    end
    r = result[0]
    py_err = result[1]
    if r != 0
      error_info = extract_python_error
      debug_log("exec:error rc=#{r} py_err=#{py_err} error=#{error_info}")
      with_gil do
      end
      raise CrythonError.new("Error executing Python code#{error_info ? " - #{error_info}" : ""}")
    end
  end

  # Evaluate a Python expression and return the result as PyObject.
  def self.eval(code : String) : PyObject
    debug_log("eval:start bytes=#{code.bytesize} preview=#{eval_preview(code)}")
    result = with_gil do
      code_obj = LibPython.compile_string(code.to_unsafe, "<crython-eval>".to_unsafe, PY_EVAL_INPUT)
      if code_obj.null?
        error_info = extract_python_error
        msg = "Error evaluating Python expression#{error_info ? " - #{error_info}" : ""}"
        if error_info && error_info.includes?("SyntaxError")
          msg += " (Use Crython.exec for statements)"
        end
        raise CrythonError.new(msg)
      end

      begin
        main_mod = LibPython.import("__main__")
        if main_mod.null?
          error_info = extract_python_error
          raise ImportError.new("__main__", error_info)
        end

        begin
          main_dict = LibPython.object_get_attr_string(main_mod, "__dict__".to_unsafe)
          if main_dict.null?
            error_info = extract_python_error
            raise AttributeError.new("__main__", "__dict__", error_info)
          end

          begin
            value = LibPython.eval_eval_code(code_obj, main_dict, main_dict)
            if value.null?
              error_info = extract_python_error
              raise CrythonError.new("Error evaluating Python expression#{error_info ? " - #{error_info}" : ""}")
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

    debug_log("eval:done")
    PyObject.from_owned(result)
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
