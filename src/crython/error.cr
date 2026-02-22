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

  # Whether the Python interpreter raised an error.
  def self.err_occurred? : Bool
    with_gil do
      !LibPython.err_occurred.null?
    end
  end

  # Clear the current Python error state
  def self.clear_error
    with_gil do
      LibPython.err_clear
    end
  end

  # Helper method to extract Python error information
  def self.extract_python_error : String?
    with_gil do
      return nil if LibPython.err_occurred.null?

      # Fetch the exception type, value, and traceback
      exc_type_ptr = uninitialized LibPython::PyObject
      exc_value_ptr = uninitialized LibPython::PyObject
      exc_tb_ptr = uninitialized LibPython::PyObject

      LibPython.err_fetch(pointerof(exc_type_ptr), pointerof(exc_value_ptr), pointerof(exc_tb_ptr))

      # Normalize the exception
      LibPython.err_normalize_exception(pointerof(exc_type_ptr), pointerof(exc_value_ptr), pointerof(exc_tb_ptr))

      error_message = ""

      # Get the exception type name
      if !exc_type_ptr.null?
        exc_type_obj = PyObject.new(exc_type_ptr)
        error_name_obj = exc_type_obj.attr("__name__")
        error_message = error_name_obj.to_s
        if error_name_obj.need_decref
          LibPython.decref(error_name_obj.to_unsafe)
          error_name_obj.need_decref = false
        end
        LibPython.decref(exc_type_ptr)
      end

      # Get the exception message
      if !exc_value_ptr.null?
        exc_value_obj = PyObject.new(exc_value_ptr)
        exc_str = exc_value_obj.to_s
        error_message += ": #{exc_str}" unless exc_str.empty?
        LibPython.decref(exc_value_ptr)
      end

      # Decref traceback if present
      if !exc_tb_ptr.null?
        LibPython.decref(exc_tb_ptr)
      end

      error_message.empty? ? nil : error_message
    end
  end
end
