module Crython
  # Base class for all Crython exceptions
  class CrythonError < Exception
  end

  # Raised when an error occurs during Python module import
  class ImportError < CrythonError
    def initialize(module_name : String, original_error : String? = nil)
      message = "Error importing module: #{module_name}"
      message += " - #{original_error}" if original_error
      super(message)
    end
  end

  # Raised when an error occurs while accessing a Python attribute
  class AttributeError < CrythonError
    def initialize(object_type : String, attribute_name : String, original_error : String? = nil)
      message = "Error accessing attribute '#{attribute_name}' on object of type '#{object_type}'"
      message += " - #{original_error}" if original_error
      super(message)
    end
  end

  # Raised when an error occurs while calling a Python method
  class CallError < CrythonError
    def initialize(method_name : String, original_error : String? = nil)
      message = "Error calling method '#{method_name}'"
      message += " - #{original_error}" if original_error
      super(message)
    end
  end

  # Raised when an error occurs while accessing an item in a Python collection
  class ItemError < CrythonError
    def initialize(original_error : String? = nil)
      message = "Error accessing item"
      message += " - #{original_error}" if original_error
      super(message)
    end
  end

  # Raised when a Python type conversion error occurs
  class TypeError < CrythonError
    def initialize(from_type : String, to_type : String, original_error : String? = nil)
      message = "Error converting from '#{from_type}' to '#{to_type}'"
      message += " - #{original_error}" if original_error
      super(message)
    end
  end

  # Raised when a Python value error occurs
  class ValueError < CrythonError
    def initialize(message : String)
      super(message)
    end
  end

  # Helper method to extract Python error information
  def self.extract_python_error : String?
    return nil unless err_occurred?

    # Get error type and message
    error_type = LibPython.err_occurred
    if error_type.null?
      return nil
    end

    # Store the error in a local variable
    error_type_obj = PyObject.new(error_type)
    error_type_name = error_type_obj.attr("__name__").to_s

    # Get the error message
    # Note: This is a simplified approach, a more robust implementation would
    # fetch the actual exception instance and its message

    # Clear the error to avoid interference with future operations
    clear_error

    error_type_name
  end
end
