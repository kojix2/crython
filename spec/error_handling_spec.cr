require "./spec_helper"

describe "Error handling" do
  describe "ImportError" do
    it "raises ImportError for non-existent module" do
      Crython.session do
        expect_raises(Crython::ImportError, /Error importing module: non_existent_module/) do
          Crython.import("non_existent_module")
        end
      end
    end
  end

  describe "AttributeError" do
    it "raises AttributeError for non-existent attribute" do
      Crython.session do
        mod = Crython.import("math")
        expect_raises(Crython::AttributeError, /Error accessing attribute 'non_existent_attribute'/) do
          mod.non_existent_attribute
        end
      end
    end
  end

  describe "CallError" do
    it "raises CallError when calling a method with invalid arguments" do
      Crython.session do
        mod = Crython.import("math")
        expect_raises(Crython::CallError, /Error calling method 'sqrt'/) do
          # sqrt expects a number, not a string
          mod.sqrt("not a number")
        end
      end
    end
  end

  describe "ItemError" do
    pending "NumPy tests are skipped if NumPy is not available" do
      it "raises ItemError when accessing an invalid index" do
        Crython.session do
          begin
            np = Crython.import("numpy")
            array = np.array([1, 2, 3])
            expect_raises(Crython::ItemError) do
              # Accessing index 10 which is out of bounds
              array[10]
            end
          rescue Crython::ImportError
            skip "NumPy is not available"
          end
        end
      end

      it "raises ItemError when setting an invalid index" do
        Crython.session do
          begin
            np = Crython.import("numpy")
            array = np.array([1, 2, 3])
            expect_raises(Crython::ItemError) do
              # Setting index 10 which is out of bounds
              array[10] = 100
            end
          rescue Crython::ImportError
            skip "NumPy is not available"
          end
        end
      end
    end
  end

  describe "TypeError" do
    it "raises TypeError when converting incompatible types" do
      Crython.session do
        # Create a Python object with an unsupported type (e.g., a custom class)
        Crython.eval(<<-PYTHON
        class CustomClass:
            pass

        custom_obj = CustomClass()
        PYTHON
        )

        mod = Crython.import("__main__")
        custom_obj = mod.custom_obj

        expect_raises(Crython::TypeError, /Unsupported Python type/) do
          custom_obj.to_cr
        end
      end
    end
  end

  describe "ValueError" do
    it "raises ValueError for invalid values" do
      Crython.session do
        mod = Crython.import("math")
        expect_raises(Crython::CallError, /ValueError/) do
          mod.sqrt(-1)  # sqrt of negative number
        end
      end
    end

    it "raises ValueError for integer overflow" do
      Crython.session do
        # Create a Python integer that's too large for Crystal's Int64
        Crython.eval(<<-PYTHON
        huge_int = 2**100  # Much larger than Int64.MAX
        PYTHON
        )

        mod = Crython.import("__main__")
        huge_int = mod.huge_int

        # This should raise a ValueError when trying to convert to Crystal
        expect_raises(Crython::ValueError, /overflow/i) do
          huge_int.to_cr
        end
      end
    end
  end

  describe "Error information extraction" do
    it "extracts Python error type information" do
      Crython.session do
        begin
          mod = Crython.import("math")
          mod.sqrt("not a number")
        rescue e : Crython::CallError
          # Convert message to string to handle nil case
          message = e.message.to_s
          message.should_not eq("")
          message.should contain("TypeError")
        end
      end
    end
  end

  describe "Nested error handling" do
    it "handles errors in nested Python calls" do
      Crython.session do
        Crython.eval(<<-PYTHON
        def outer_function():
            return inner_function()

        def inner_function():
            raise ValueError("Inner function error")
        PYTHON
        )

        mod = Crython.import("__main__")
        expect_raises(Crython::CallError, /ValueError/) do
          mod.outer_function
        end
      end
    end
  end
end
