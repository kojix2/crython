module Crython
  # Whether the Python interpreter raised an error.
  def self.err_occurred? : Bool
    !LibPython.err_occurred.null?
  end

  def self.clear_error
    LibPython.err_clear
  end
end
