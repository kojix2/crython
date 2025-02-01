require "./spec_helper"

describe Crython do
  it "loads" do
    Crython.init
    Crython.initialized?.should be_true
    Crython.finalize
    Crython.initialized?.should be_false
  end

  it "embeds Python" do
    Crython.embed_python do
      Crython.initialized?.should be_true
    end
    Crython.initialized?.should be_false
  end

  it "gets Python version" do
    Crython.embed_python do
      Crython.python_version.should be_a(String)
    end
  end

  it "gets Python build info" do
    Crython.embed_python do
      Crython.python_build_info.should be_a(String)
    end
  end

  it "gets Python compiler" do
    Crython.embed_python do
      Crython.python_compiler.should be_a(String)
    end
  end

  it "raises error" do
    Crython.embed_python do
      Crython.err_occurred?.should be_false
      LibPython.import("nonexistent")
      Crython.err_occurred?.should be_true
      Crython.clear_error
      Crython.err_occurred?.should be_false
    end
  end

  it "imports a Python module" do
    Crython.embed_python do
      mod = Crython.import("math")
      mod.should be_a(Crython::PyObject)
    end
  end
end
