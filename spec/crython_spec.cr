require "./spec_helper"

private class FailingToPy
  def to_py : Crython::PyObject
    raise Crython::CrythonError.new("intentional conversion failure")
  end
end

describe Crython do
  it "has a version" do
    Crython::VERSION.should be_a(String)
  end

  it "loads" do
    Crython.init
    Crython.initialized?.should be_true
    Crython.initialized?.should be_true
  end

  it "embeds Python" do
    with_crython do
      Crython.initialized?.should be_true
    end
    Crython.initialized?.should be_true
    Crython.initialized?.should be_true
  end

  it "gets Python version" do
    with_crython do
      Crython.python_version.should be_a(String)
    end
  end

  it "gets Python build info" do
    with_crython do
      Crython.python_build_info.should be_a(String)
    end
  end

  it "gets Python compiler" do
    with_crython do
      Crython.python_compiler.should be_a(String)
    end
  end

  it "raises error" do
    with_crython do
      Crython.err_occurred?.should be_false
      math = Crython.import("math")
      Crython::LibPython.object_get_attr_string(math.to_unsafe, "non_existent_attribute".to_unsafe)
      Crython.err_occurred?.should be_true
      Crython.clear_error
      Crython.err_occurred?.should be_false
    end
  end

  it "imports a Python module" do
    with_crython do
      mod = Crython.import("math")
      mod.should be_a(Crython::PyObject)
    end
  end

  it "imports a Python module with import?" do
    with_crython do
      mod = Crython.import?("math")
      mod.should be_a(Crython::PyObject)
    end
  end

  it "returns nil with import? for non-existent module" do
    with_crython do
      mod = Crython.import?("non_existent_module")
      mod.should be_nil
    end
  end

  it "evaluates Python expressions and returns a PyObject" do
    with_crython do
      result = Crython.eval("1 + 2")
      result.should be_a(Crython::PyObject)
      result.to_cr.should eq(3)
    end
  end

  it "raises guidance when eval is used with statements" do
    with_crython do
      expect_raises(Crython::CrythonError, /Use Crython.exec for statements/) do
        Crython.eval("x = 10")
      end
    end
  end

  it "executes Python statements with exec" do
    with_crython do
      Crython.exec("x = 10")
      value = Crython.eval("x")
      value.to_cr.should eq(10)
    end
  end

  it "clears Python error state after exception extraction" do
    with_crython do
      expect_raises(Crython::CrythonError, /ZeroDivisionError: division by zero/) do
        Crython.eval("1 / 0")
      end
      Crython.err_occurred?.should be_false
      Crython.eval("6 * 7").to_i64.should eq(42)
    end
  end

  it "turns SystemExit into a Crython error and remains usable" do
    with_crython do
      expect_raises(Crython::CrythonError, /SystemExit/) do
        Crython.exec("raise SystemExit(7)")
      end
      Crython.eval("6 * 7").to_i64.should eq(42)
    end
  end

  it "cleans up partially constructed containers after conversion failure" do
    with_crython do
      failing = FailingToPy.new

      expect_raises(Crython::CrythonError, /intentional conversion failure/) { [1, failing].to_py }
      expect_raises(Crython::CrythonError, /intentional conversion failure/) { {1, failing}.to_py }
      expect_raises(Crython::CrythonError, /intentional conversion failure/) { {"ok" => 1, "bad" => failing}.to_py }
      expect_raises(Crython::CrythonError, /intentional conversion failure/) { NamedTuple.new(ok: 1, bad: failing).to_py }

      Crython.eval("6 * 7").to_i64.should eq(42)
    end
  end

  it "keeps source wrappers valid after container conversion" do
    with_crython do
      value = "still alive".to_py
      key = "key".to_py

      begin
        [value, value].to_py
        {value, value}.to_py
        {key => value}.to_py
        NamedTuple.new(value: value).to_py
      end
      GC.collect

      value.to_cr.should eq("still alive")
      key.to_cr.should eq("key")
    end
  end

  it "preserves embedded NUL bytes in strings" do
    with_crython do
      value = "before\0after"
      value.to_py.to_cr.should eq(value)
      String.new(value.to_py).should eq(value)
    end
  end

  it "invokes a callable object directly" do
    with_crython do
      Crython.exec("def __crython_add(a, b):\n    return a + b")
      callable = Crython.import("__main__").attr("__crython_add")
      callable.invoke(20, 22).to_i64.should eq(42)
    end
  end

  it "initializes idempotently" do
    Crython.init
    Crython.init
    Crython.eval("40 + 2").to_i64.should eq(42)
  end
end
