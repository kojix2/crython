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

  describe "explicit call()" do
    it "supports uppercase Python attribute names" do
      Crython.session do
        collections = Crython.import("collections")
        counter = collections.call("Counter", [1, 2, 1, 3].to_py)

        counter.should be_a(Crython::PyObject)
        counter[1].to_cr.should eq(2)
        counter[2].to_cr.should eq(1)
        counter[3].to_cr.should eq(1)
      end
    end

    it "supports builtins with positional arguments" do
      Crython.session do
        builtins = Crython.import("builtins")
        result = builtins.call("sum", [1, 2, 3, 4].to_py)

        result.to_cr.should eq(10)
      end
    end

    it "shows actionable guidance for uppercase method syntax" do
      code = <<-CR
        require "./src/crython"

        Crython.session do
          collections = Crython.import("collections")
          collections.Counter([1, 2, 1, 3].to_py)
        end
      CR

      stdout = IO::Memory.new
      stderr = IO::Memory.new
      status = Process.run(
        "crystal",
        ["eval", code, "--no-color"],
        output: stdout,
        error: stderr,
        chdir: File.expand_path("..", __DIR__)
      )

      status.success?.should be_false
      (stdout.to_s + stderr.to_s).should contain("Uppercase Python attributes must use call(\"Name\", ...)")
    end
  end

  describe "multiple assignment" do
    it "supports destructuring a Python tuple" do
      Crython.session do
        Crython.eval("def __crython_pair():\n    return (10, 20)")

        main = Crython.import("__main__")
        x, y = main.__crython_pair

        x.to_cr.should eq(10)
        y.to_cr.should eq(20)
      end
    end

    it "raises ItemError when destructuring needs more elements than available" do
      Crython.session do
        Crython.eval("def __crython_pair():\n    return (10, 20)")

        main = Crython.import("__main__")
        expect_raises(Crython::ItemError) do
          _a, _b, _c = main.__crython_pair
        end
      end
    end
  end
end
