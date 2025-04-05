require "./spec_helper"

describe Crython::PyObject do
  describe "#to_cr" do
    it "converts Python int to Crystal Int64" do
      Crython.session do
        pyobject = 42.to_py
        pyobject.to_cr.should be_a(Int64)
        pyobject.to_cr.should eq(42)
      end
    end

    it "converts Python float to Crystal Float64" do
      Crython.session do
        pyobject = 3.14.to_py
        pyobject.to_cr.should be_a(Float64)
        pyobject.to_cr.should eq(3.14)
      end
    end

    it "converts Python str to Crystal String" do
      Crython.session do
        pyobject = "hello".to_py
        pyobject.to_cr.should be_a(String)
        pyobject.to_cr.should eq("hello")
      end
    end

    it "converts Python bool to Crystal Bool" do
      Crython.session do
        py_true = true.to_py
        py_true.to_cr.should be_a(Bool)
        py_true.to_cr.should eq(true)

        py_false = false.to_py
        py_false.to_cr.should be_a(Bool)
        py_false.to_cr.should eq(false)
      end
    end

    it "converts Python None to Crystal nil" do
      Crython.session do
        pyobject = nil.to_py
        pyobject.to_cr.should be_a(Nil)
        pyobject.to_cr.should eq(nil)
      end
    end

    it "converts Python list to Crystal Array-like object" do
      Crython.session do
        pyobject = [1, 2, 3].to_py
        result = pyobject.to_cr
        result.responds_to?(:size).should be_true
        result.responds_to?(:each).should be_true
      end
    end

    it "converts Python tuple to Crystal Array-like object" do
      Crython.session do
        # Create a Python tuple
        Crython.eval("import sys; sys.modules['__main__'].__dict__['result'] = (1, 2, 3)")
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        result = pyobject.to_cr
        result.responds_to?(:size).should be_true
        result.responds_to?(:each).should be_true
      end
    end

    it "converts Python dict to Crystal Hash-like object" do
      Crython.session do
        # Create a Python dict
        Crython.eval("import sys; sys.modules['__main__'].__dict__['result'] = {'a': 1, 'b': 2, 'c': 3}")
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        result = pyobject.to_cr
        result.responds_to?(:size).should be_true
        result.responds_to?(:each).should be_true
        result.responds_to?(:keys).should be_true
        result.responds_to?(:values).should be_true
      end
    end

    it "converts Python complex to Crystal Complex" do
      Crython.session do
        # Create a Python complex
        Crython.eval("import sys; sys.modules['__main__'].__dict__['result'] = complex(3.14, 2.71)")
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        result = pyobject.to_cr
        result.should be_a(Complex)
      end
    end

    it "handles large integers with overflow check" do
      Crython.session do
        # Create a Python int that's large but within Int64 range
        Crython.eval("import sys; sys.modules['__main__'].__dict__['result'] = 2**60")
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        # Should convert to Int64 via string representation
        result = pyobject.to_cr
        result.should be_a(Int64)
        result.should eq(2_i64**60)
      end
    end
  end
end
