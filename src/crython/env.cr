module Crython
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
  # @session_id (UInt64)
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

  @@session_id : UInt64 = 0
  @@session_active : Bool = false

  def self.session_id : UInt64
    @@session_id
  end

  # Initialize a Python interpreter
  def self.init
    debug_log("init:start initialized=#{LibPython.is_initialized != 0} session_id=#{@@session_id} active=#{@@session_active}")
    unless LibPython.is_initialized != 0
      LibPython.init
      debug_log("init:python runtime initialized")
    end
    @@session_id = @@session_id &+ 1
    @@session_active = true
    debug_log("init:done session_id=#{@@session_id} active=#{@@session_active}")
  end

  # Check if Crython logical session is initialized
  def self.initialized? : Bool
    @@session_active
  end

  # Finalize Crython logical session
  def self.finalize
    if initialized?
      debug_log("finalize:start session_id=#{@@session_id} active=#{@@session_active}")
      @@session_active = false
      # no-op: Python runtime remains initialized and is reused
      debug_log("finalize:done session_id=#{@@session_id} active=#{@@session_active}")
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

  # Evaluate Python code with error handling
  def self.eval(code : String) : Nil
    debug_log("eval:start session_id=#{@@session_id} active=#{@@session_active} bytes=#{code.bytesize} preview=#{eval_preview(code)}")
    result = with_gil do
      rc = LibPython.run_simple_string(code.to_unsafe)
      py_err = !LibPython.err_occurred.null?
      debug_log("eval:done rc=#{rc} py_err=#{py_err} session_id=#{@@session_id} active=#{@@session_active}")
      {rc, py_err}
    end
    r = result[0]
    py_err = result[1]
    if r != 0
      error_info = extract_python_error
      debug_log("eval:error rc=#{r} py_err=#{py_err} error=#{error_info}")
      with_gil do
        LibPython.err_print
      end
      raise CrythonError.new("Error evaluating Python code#{error_info ? " - #{error_info}" : ""}")
    end
  end

  # Check if the current session is active
  def self.active_session?(id : UInt64) : Bool
    id == @@session_id && initialized?
  end
end
