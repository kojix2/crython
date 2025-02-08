require "./spec_helper"

describe Number do
  it "long converts to Crystal" do
    Crython.session do
      py_long = 255.to_py
      py_long.should be_a(Crython::PyObject)
      py_long.to_cr.should eq(255)
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

  it "UInt8 converts from Python" do
    Crython.session do
      pyobject = 255.to_py
      UInt8.new(pyobject).should eq(255)
    end
  end

  it "Int8 converts from Python" do
    Crython.session do
      pyobject = (-128).to_py
      Int8.new(pyobject).should eq(-128)
    end
  end

  it "UInt16 converts from Python" do
    Crython.session do
      pyobject = 65535.to_py
      UInt16.new(pyobject).should eq(65535)
    end
  end

  it "Int16 converts from Python" do
    Crython.session do
      pyobject = (-32768).to_py
      Int16.new(pyobject).should eq(-32768)
    end
  end

  it "UInt32 converts from Python" do
    Crython.session do
      pyobject = 4294967295.to_py
      UInt32.new(pyobject).should eq(4294967295)
    end
  end

  it "Int32 converts from Python" do
    Crython.session do
      pyobject = (-2147483648).to_py
      Int32.new(pyobject).should eq(-2147483648)
    end
  end

  it "UInt64 converts from Python" do
    Crython.session do
      pyobject = 18446744073709551615_u64.to_py
      UInt64.new(pyobject).should eq(18446744073709551615_u64)
    end
  end

  it "Int64 converts from Python" do
    Crython.session do
      pyobject = (-9223372036854775808).to_py
      Int64.new(pyobject).should eq(-9223372036854775808)
    end
  end

  it "UInt128 converts from Python" do
    Crython.session do
      pyobject = 340282366920938463463374607431768211455_u128.to_py
      UInt128.new(pyobject).should eq(340282366920938463463374607431768211455_u128)
    end
  end

  it "Int128 converts from Python" do
    Crython.session do
      pyobject = (-170141183460469231731687303715884105728_i128).to_py
      Int128.new(pyobject).should eq(-170141183460469231731687303715884105728_i128)
    end
  end

  it "Float32 converts from Python" do
    Crython.session do
      pyobject = 3.14.to_py
      Float32.new(pyobject).should eq(3.14.to_f32)
    end
  end

  it "Float64 converts from Python" do
    Crython.session do
      pyobject = 3.14.to_py
      Float64.new(pyobject).should eq(3.14)
    end
  end
end
