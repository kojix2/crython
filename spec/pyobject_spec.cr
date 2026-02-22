require "./spec_helper"

describe Crython::PyObject do
  describe "reference management" do
    it "keeps PyObject usable after args-only and kwargs calls" do
      Crython.session do
        Crython.eval("def __crython_ref_f(x):\n    return None")
        Crython.eval("def __crython_ref_g(*, x):\n    return None")

        main = Crython.import("__main__")
        obj = [1, 2, 3].to_py

        main.__crython_ref_f(obj)
        obj.__len__.to_cr.should eq(3)

        main.__crython_ref_g(x: obj)
        obj.__len__.to_cr.should eq(3)
      end
    end

    it "supports single-key [] and []= with PyObject key/value" do
      Crython.session do
        py_dict = ({"a" => 1} of String => Int32).to_py

        py_key = "x".to_py
        py_value = 42.to_py
        py_dict[py_key] = py_value

        py_dict["a"].to_cr.should eq(1)
        py_dict["x"].to_cr.should eq(42)
      end
    end
  end

  describe "attr?" do
    it "returns attribute when present" do
      Crython.session do
        math = Crython.import("math")
        pi = math.attr?("pi")
        pi.should be_a(Crython::PyObject)
        pi.not_nil!.to_cr.should be_a(Float64)
      end
    end

    it "returns nil when attribute is missing" do
      Crython.session do
        math = Crython.import("math")
        missing = math.attr?("non_existent_attribute")
        missing.should be_nil
      end
    end
  end

  describe "call?" do
    it "returns value when call succeeds" do
      Crython.session do
        math = Crython.import("math")
        result = math.call?("pow", 2, 3)
        result.should be_a(Crython::PyObject)
        result.not_nil!.to_cr.should eq(8.0)
      end
    end

    it "returns nil when method is missing" do
      Crython.session do
        math = Crython.import("math")
        result = math.call?("non_existent_method")
        result.should be_nil
      end
    end

    it "returns nil when call arguments are invalid" do
      Crython.session do
        math = Crython.import("math")
        result = math.call?("pow")
        result.should be_nil
      end
    end
  end
end
