module Crython
  # Initialize a Python interpreter.
  def self.init
    unless Crython.initialized?
      LibPython.init
    end
  end

  # Whether the Python interpreter has been initialized.
  def self.initialized? : Bool
    LibPython.is_initialized != 0
  end

  # Finalize embedded Python interpreter.
  def self.finalize
    if Crython.initialized?
      LibPython.finalize
    end
  end

  def self.embed_python(&)
    LibPython.init
    yield(self)
    LibPython.finalize
  end

  def self.python_version : String
    String.new(LibPython.get_version)
  end

  def self.python_build_info : String
    String.new(LibPython.get_build_info)
  end

  def self.python_compiler : String
    String.new(LibPython.get_compiler)
  end

  def self.eval(code : String) : Nil
    r = LibPython.run_simple_string(code.to_unsafe)
    if r != 0
      LibPython.err_print
      raise "Error evaluating Python code"
    end
  end
end
