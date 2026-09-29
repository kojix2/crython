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

  # Extract the current Python exception while the GIL is held, then clear
  # it from CPython and release every owned reference before returning.
  def self.extract_python_error : String?
    with_gil do
      return nil if LibPython.err_occurred.null?

      exc_type = Pointer(Void).null.as(LibPython::PyObject)
      exc_value = Pointer(Void).null.as(LibPython::PyObject)
      exc_traceback = Pointer(Void).null.as(LibPython::PyObject)
      LibPython.err_fetch(pointerof(exc_type), pointerof(exc_value), pointerof(exc_traceback))
      LibPython.err_normalize_exception(pointerof(exc_type), pointerof(exc_value), pointerof(exc_traceback))

      begin
        type_name = exception_type_name(exc_type)
        message = exception_object_string(exc_value)
        message && !message.empty? ? "#{type_name}: #{message}" : type_name
      ensure
        LibPython.decref(exc_traceback) unless exc_traceback.null?
        LibPython.decref(exc_value) unless exc_value.null?
        LibPython.decref(exc_type) unless exc_type.null?
      end
    end
  end

  private def self.exception_type_name(exception_type : LibPython::PyObject) : String
    return "PythonError" if exception_type.null?

    name = LibPython.object_get_attr_string(exception_type, "__name__".to_unsafe)
    if name.null?
      LibPython.err_clear
      return "PythonError"
    end

    begin
      exception_object_string(name) || "PythonError"
    ensure
      LibPython.decref(name)
    end
  end

  private def self.exception_object_string(object : LibPython::PyObject) : String?
    return nil if object.null?

    string = LibPython.object_str(object)
    if string.null?
      LibPython.err_clear
      return nil
    end

    begin
      bytesize = uninitialized LibC::SSizeT
      ptr = LibPython.unicode_as_utf8_and_size(string, pointerof(bytesize))
      if ptr.null?
        LibPython.err_clear
        return nil
      end
      String.new(ptr, bytesize.to_i)
    ensure
      LibPython.decref(string)
    end
  end
end
