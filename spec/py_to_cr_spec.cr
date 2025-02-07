require "./spec_helper"

describe Number do
  it "long converts to Crystal" do
    Crython.session do
      py_long = 256.to_py
      py_long.should be_a(Crython::PyObject)
      py_long.to_cr.should eq(256)
    end
  end

  it "float converts to Crystal" do
    Crython.session do
      py_float = 3.14.to_py
      py_float.should be_a(Crython::PyObject)
      py_float.to_cr.should eq(3.14)
    end
  end

  it "string converts to Crystal" do
    Crython.session do
      py_str = "hello".to_py
      py_str.should be_a(Crython::PyObject)
      py_str.to_cr.should eq("hello")
    end
  end
end
