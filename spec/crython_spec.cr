require "./spec_helper"

describe Crython do
  it "has a version" do
    Crython::VERSION.should be_a(String)
  end

  it "loads" do
    Crython.init
    Crython.initialized?.should be_true
    Crython.finalize
    Crython.initialized?.should be_false
  end

  it "embeds Python" do
    Crython.session do
      Crython.initialized?.should be_true
    end
    Crython.initialized?.should be_false
  end

  it "gets Python version" do
    Crython.session do
      Crython.python_version.should be_a(String)
    end
  end

  it "gets Python build info" do
    Crython.session do
      Crython.python_build_info.should be_a(String)
    end
  end

  it "gets Python compiler" do
    Crython.session do
      Crython.python_compiler.should be_a(String)
    end
  end

  it "raises error" do
    Crython.session do
      Crython.err_occurred?.should be_false
      Crython::LibPython.import("nonexistent")
      Crython.err_occurred?.should be_true
      Crython.clear_error
      Crython.err_occurred?.should be_false
    end
  end

  it "imports a Python module" do
    Crython.session do
      mod = Crython.import("math")
      mod.should be_a(Crython::PyObject)
    end
  end
end
