module Crython
  struct PythonErrorInfo
    getter type_name : String
    getter message : String
    getter traceback : String?
    getter name : String?

    def initialize(@type_name : String, @message : String, @traceback : String?, @name : String?)
    end

    def to_s(io : IO) : Nil
      io << @type_name
      io << ": " << @message unless @message.empty?
    end
  end

  # Base class for all Crython exceptions
  class CrythonError < Exception
    getter python_error : PythonErrorInfo?

    def initialize(message : String, @python_error : PythonErrorInfo? = nil)
      super(message)
    end
  end

  # Raised when an error occurs during Python module import
  class ImportError < CrythonError
    def initialize(module_name : String, original_error : String? = nil, python_error : PythonErrorInfo? = nil)
      message = "Error importing module: #{module_name}"
      message += " - #{original_error}" if original_error
      super(message, python_error)
    end
  end

  # Raised when an error occurs while accessing a Python attribute
  class AttributeError < CrythonError
    def initialize(object_type : String, attribute_name : String, original_error : String? = nil, python_error : PythonErrorInfo? = nil)
      message = "Error accessing attribute '#{attribute_name}' on object of type '#{object_type}'"
      message += " - #{original_error}" if original_error
      super(message, python_error)
    end
  end

  # Raised when an error occurs while calling a Python method
  class CallError < CrythonError
    def initialize(method_name : String, original_error : String? = nil, python_error : PythonErrorInfo? = nil)
      message = "Error calling method '#{method_name}'"
      message += " - #{original_error}" if original_error
      super(message, python_error)
    end
  end

  # Raised when an error occurs while accessing an item in a Python collection
  class ItemError < CrythonError
    def initialize(original_error : String? = nil, python_error : PythonErrorInfo? = nil)
      message = "Error accessing item"
      message += " - #{original_error}" if original_error
      super(message, python_error)
    end
  end

  # Raised when a Python type conversion error occurs
  class TypeError < CrythonError
    def initialize(from_type : String, to_type : String, original_error : String? = nil, python_error : PythonErrorInfo? = nil)
      message = "Error converting from '#{from_type}' to '#{to_type}'"
      message += " - #{original_error}" if original_error
      super(message, python_error)
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

  # Capture and clear the current Python exception while the GIL is held.
  def self.capture_python_error : PythonErrorInfo?
    with_gil do
      return if LibPython.err_occurred.null?

      raised = LibPython.err_get_raised_exception
      return if raised.null?
      type_object = Pointer(Void).null.as(LibPython::PyObject)
      begin
        type_object = LibPython.object_get_attr_string(raised, "__class__".to_unsafe)
        type_name = exception_type_name(type_object)
        message = exception_object_string(raised) || ""
        traceback_size = uninitialized LibC::SizeT
        traceback_ptr = LibCrythonRuntime.format_exception(raised, pointerof(traceback_size))
        traceback = nil
        unless traceback_ptr.null?
          begin
            traceback = String.new(traceback_ptr, traceback_size.to_i)
          ensure
            LibCrythonRuntime.free_string(traceback_ptr)
          end
        end
        PythonErrorInfo.new(type_name, message, traceback, exception_attribute_string(raised, "name"))
      ensure
        LibPython.decref(type_object) unless type_object.null?
        LibPython.decref(raised)
      end
    end
  end

  def self.extract_python_error : String?
    capture_python_error.try(&.to_s)
  end

  private def self.exception_attribute_string(object : LibPython::PyObject, name : String) : String?
    value = LibPython.object_get_attr_string(object, name.to_unsafe)
    if value.null?
      LibPython.err_clear
      return
    end
    begin
      result = exception_object_string(value)
      result == "None" ? nil : result
    ensure
      LibPython.decref(value)
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
    return if object.null?

    string = LibPython.object_str(object)
    if string.null?
      LibPython.err_clear
      return
    end

    begin
      bytesize = uninitialized LibC::SSizeT
      ptr = LibPython.unicode_as_utf8_and_size(string, pointerof(bytesize))
      if ptr.null?
        LibPython.err_clear
        return
      end
      String.new(ptr, bytesize.to_i)
    ensure
      LibPython.decref(string)
    end
  end
end
