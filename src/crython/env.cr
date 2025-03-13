module Crython
  # ===============================================================
  # @session_id (UInt64)
  # ===============================================================
  # Purpose:
  # - Acts as a unique identifier for each Python interpreter session.
  # - Increments with each initialization (wraps around on overflow).
  # - Ensures that Python objects managed by Crystal's GC can safely
  #   determine if the associated Python interpreter is still active.
  #
  # Why it's needed:
  # - Prevents double-free or invalid memory access when Crystal's GC
  #   tries to finalize objects after the Python interpreter has been
  #   shut down (via LibPython.finalize).
  # - By checking the session_id, we ensure that decref operations
  #   are only performed if the session is still valid.
  # ===============================================================

  @@session_id : UInt64 = 0

  def self.session_id : UInt64
    @@session_id
  end

  # Initialize a Python interpreter
  def self.init
    @@session_id = @@session_id &+ 1
    unless initialized?
      LibPython.init
    end
  end

  # Check if Python interpreter is initialized
  def self.initialized? : Bool
    LibPython.is_initialized != 0
  end

  # Finalize Python interpreter
  def self.finalize
    if initialized?
      LibPython.finalize
      @@session_id = 0 # Invalidate ID after finalize
    end
  end

  # Embed Python execution
  def self.session(&)
    init
    yield(self)
    finalize
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
