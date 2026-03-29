require "set"

module Crython
  record SessionToken, id : UInt64, generation : UInt64

  PY_SINGLE_INPUT = 256
  PY_FILE_INPUT = 257
  PY_EVAL_INPUT = 258

  def self.debug_enabled? : Bool
    ENV["CRYTHON_DEBUG"]? == "1"
  end

  def self.with_gil(&)
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

  # ===============================================================
  # @session_token (SessionToken)
  # ===============================================================
  # Purpose:
  # - Acts as a unique identifier for each logical Crython session.
  # - Increments on each `init` call (wraps around on overflow).
  # - Ensures that Python objects managed by Crystal's GC can safely
  #   determine if the current logical session is still active.
  #
  # Runtime model:
  # - The embedded Python interpreter is initialized once and reused.
  # - Crython does not call `Py_Finalize` during normal session flow.
  # - `finalize` ends the logical Crython session only.
  # ===============================================================

  @@session_counter : UInt64 = 0
  @@session_generation : UInt64 = 0
  @@current_session_token = SessionToken.new(0_u64, 0_u64)
  @@session_active : Bool = false
  @@sealed_sessions = Set(SessionToken).new

  def self.session_token : SessionToken
    @@current_session_token
  end

  # Initialize a Python interpreter
  def self.init
    debug_log("init:start initialized=#{LibPython.is_initialized != 0} session_token=#{@@current_session_token} active=#{@@session_active}")
    unless LibPython.is_initialized != 0
      LibPython.init
      debug_log("init:python runtime initialized")
    end
    prev_session_counter = @@session_counter
    @@session_counter = @@session_counter &+ 1
    if @@session_counter < prev_session_counter
      @@session_generation = @@session_generation &+ 1
    end
    @@current_session_token = SessionToken.new(@@session_counter, @@session_generation)
    @@session_active = true
    @@sealed_sessions.delete(@@current_session_token)
    debug_log("init:done session_token=#{@@current_session_token} active=#{@@session_active}")
  end

  # Check if Crython logical session is initialized
  def self.initialized? : Bool
    @@session_active
  end

  # Finalize Crython logical session
  def self.finalize
    if initialized?
      debug_log("finalize:start session_token=#{@@current_session_token} active=#{@@session_active}")
      @@sealed_sessions.add(@@current_session_token)
      @@session_active = false
      # no-op: Python runtime remains initialized and is reused
      debug_log("finalize:done session_token=#{@@current_session_token} active=#{@@session_active} sealed=true")
    end
  end

  # Embed Python execution
  def self.session(&)
    debug_log("session:enter")
    init
    yield(self)
    debug_log("session:leave")
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
    debug_log("exec:start session_token=#{@@current_session_token} active=#{@@session_active} bytes=#{code.bytesize} preview=#{eval_preview(code)}")
    result = with_gil do
      rc = LibPython.run_simple_string(code.to_unsafe)
      py_err = !LibPython.err_occurred.null?
      debug_log("exec:done rc=#{rc} py_err=#{py_err} session_token=#{@@current_session_token} active=#{@@session_active}")
      {rc, py_err}
    end
    r = result[0]
    py_err = result[1]
    if r != 0
      error_info = extract_python_error
      debug_log("exec:error rc=#{r} py_err=#{py_err} error=#{error_info}")
      with_gil do
        LibPython.err_print
      end
      raise CrythonError.new("Error executing Python code#{error_info ? " - #{error_info}" : ""}")
    end
  end

  # Evaluate a Python expression and return the result as PyObject.
  def self.eval(code : String) : PyObject
    debug_log("eval:start session_token=#{@@current_session_token} active=#{@@session_active} bytes=#{code.bytesize} preview=#{eval_preview(code)}")
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

    debug_log("eval:done session_token=#{@@current_session_token} active=#{@@session_active}")
    PyObject.new(result, need_decref: true)
  end

  # Check if the current session is active
  def self.active_session?(token : SessionToken) : Bool
    token == @@current_session_token && initialized?
  end

  def self.sealed_session?(token : SessionToken) : Bool
    @@sealed_sessions.includes?(token)
  end
end
