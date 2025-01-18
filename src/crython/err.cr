module Crython
  # Whether the Python interpreter raised an error.
  def self.error_occurred? : Bool
    !LibPython.error_occurred.null?
  end

  def self.clear_error
    LibPython.error_clear
  end
end
