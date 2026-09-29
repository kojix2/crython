require "./spec_helper"

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

  it "turns SystemExit into a Crython error and remains usable" do
    with_crython do
      expect_raises(Crython::CrythonError, /SystemExit/) do
        Crython.exec("raise SystemExit(7)")
      end
      Crython.eval("6 * 7").to_i64.should eq(42)
    end
  end

  it "initializes idempotently" do
    Crython.init
    Crython.init
    Crython.eval("40 + 2").to_i64.should eq(42)
  end
end
