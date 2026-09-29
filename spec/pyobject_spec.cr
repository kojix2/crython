require "./spec_helper"

describe Crython::PyObject do
  describe "reference management" do
    it "keeps PyObject usable after args-only and kwargs calls" do
      with_crython do
        Crython.exec("def __crython_ref_f(x):\n    return None")
        Crython.exec("def __crython_ref_g(*, x):\n    return None")

        main = Crython.import("__main__")
        obj = [1, 2, 3].to_py

        main.__crython_ref_f(obj)
        obj.__len__.to_cr.should eq(3)

        main.__crython_ref_g(x: obj)
        obj.__len__.to_cr.should eq(3)
      end
    end

    it "supports single-key [] and []= with PyObject key/value" do
      with_crython do
        py_dict = ({"a" => 1} of String => Int32).to_py

        py_key = "x".to_py
        py_value = 42.to_py
        py_dict[py_key] = py_value

        py_dict["a"].to_cr.should eq(1)
        py_dict["x"].to_cr.should eq(42)
      end
    end
  end

  describe "attribute mutation" do
    it "sets and deletes Python attributes" do
      with_crython do
        namespace = Crython.import("types").call("SimpleNamespace")
        namespace.answer = 42

        namespace.attr("answer").to_i64.should eq(42)
        namespace.del_attr("answer").should be_true
        namespace.attr?("answer").should be_nil
      end
    end

    it "reports a Python error when deleting a missing attribute" do
      with_crython do
        namespace = Crython.import("types").call("SimpleNamespace")
        expect_raises(Crython::AttributeError, /AttributeError/) do
          namespace.del_attr("missing")
        end
        Crython.err_occurred?.should be_false
      end
    end
  end

  describe "attr?" do
    it "returns attribute when present" do
      with_crython do
        math = Crython.import("math")
        pi = math.attr?("pi")
        pi.should be_a(Crython::PyObject)
        pi.as(Crython::PyObject).to_cr.should be_a(Float64)
      end
    end

    it "returns nil when attribute is missing" do
      with_crython do
        math = Crython.import("math")
        missing = math.attr?("non_existent_attribute")
        missing.should be_nil
      end
    end
  end

  describe "call?" do
    it "returns value when call succeeds" do
      with_crython do
        math = Crython.import("math")
        result = math.call?("pow", 2, 3)
        result.should be_a(Crython::PyObject)
        result.as(Crython::PyObject).to_cr.should eq(8.0)
      end
    end

    it "returns nil when method is missing" do
      with_crython do
        math = Crython.import("math")
        result = math.call?("non_existent_method")
        result.should be_nil
      end
    end

    it "raises when a present callable rejects its arguments" do
      with_crython do
        math = Crython.import("math")
        expect_raises(Crython::CallError, /TypeError/) { math.call?("pow") }
      end
    end
  end

  describe "explicit call()" do
    it "supports uppercase Python attribute names" do
      with_crython do
        collections = Crython.import("collections")
        counter = collections.call("Counter", [1, 2, 1, 3].to_py)

        counter.should be_a(Crython::PyObject)
        counter[1].to_cr.should eq(2)
        counter[2].to_cr.should eq(1)
        counter[3].to_cr.should eq(1)
      end
    end

    it "supports builtins with positional arguments" do
      with_crython do
        builtins = Crython.import("builtins")
        result = builtins.call("sum", [1, 2, 3, 4].to_py)

        result.to_cr.should eq(10)
      end
    end

    it "returns a non-callable attribute without invalidating it" do
      with_crython do
        math = Crython.import("math")
        pi = math.call("pi")

        pi.to_cr.should eq(Math::PI)
      end
    end

    it "shows actionable guidance for uppercase method syntax" do
      code = <<-CR
        require "./src/crython"

        Crython.init
        collections = Crython.import("collections")
        collections.Counter([1, 2, 1, 3].to_py)
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
      with_crython do
        Crython.exec("def __crython_pair():\n    return (10, 20)")

        main = Crython.import("__main__")
        x, y = main.__crython_pair

        x.to_cr.should eq(10)
        y.to_cr.should eq(20)
      end
    end

    it "raises ItemError when destructuring needs more elements than available" do
      with_crython do
        Crython.exec("def __crython_pair():\n    return (10, 20)")

        main = Crython.import("__main__")
        expect_raises(Crython::ItemError) do
          _a, _b, _c = main.__crython_pair
        end
      end
    end
  end
end
