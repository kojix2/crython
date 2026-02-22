module Crython
  def self.debug_enabled? : Bool
    ENV["CRYTHON_DEBUG"]? == "1"
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

  # Evaluate Python code with error handling
  def self.eval(code : String) : Nil
    r = LibPython.run_simple_string(code.to_unsafe)
    if r != 0
      error_info = extract_python_error
      LibPython.err_print
      raise CrythonError.new("Error evaluating Python code#{error_info ? " - #{error_info}" : ""}")
    end
  end

  # Check if the current session is active
  def self.active_session?(id : UInt64) : Bool
    id == @@session_id && initialized?
  end
end
