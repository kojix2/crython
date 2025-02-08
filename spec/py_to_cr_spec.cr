require "./spec_helper"

describe Number do
  describe UInt8 do
    it "converts from Python" do
      Crython.session do
        pyobject = 255.to_py
        UInt8.new(pyobject).should eq(255)
      end
    end
  end

  describe Int8 do
    it "converts from Python" do
      Crython.session do
        pyobject = (-128).to_py
        Int8.new(pyobject).should eq(-128)
      end
    end
  end

  describe UInt16 do
    it "converts from Python" do
      Crython.session do
        pyobject = 65535.to_py
        UInt16.new(pyobject).should eq(65535)
      end
    end
  end

  describe Int16 do
    it "converts from Python" do
      Crython.session do
        pyobject = (-32768).to_py
        Int16.new(pyobject).should eq(-32768)
      end
    end
  end

  describe UInt32 do
    it "converts from Python" do
      Crython.session do
        pyobject = 4294967295.to_py
        UInt32.new(pyobject).should eq(4294967295)
      end
    end
  end

  describe Int32 do
    it "converts from Python" do
      Crython.session do
        pyobject = (-2147483648).to_py
        Int32.new(pyobject).should eq(-2147483648)
      end
    end
  end

  describe UInt64 do
    it "converts from Python" do
      Crython.session do
        pyobject = 18446744073709551615_u64.to_py
        UInt64.new(pyobject).should eq(18446744073709551615_u64)
      end
    end
  end

  describe Int64 do
    it "converts from Python" do
      Crython.session do
        pyobject = (-9223372036854775808_i64).to_py
        Int64.new(pyobject).should eq(-9223372036854775808_i64)
      end
    end
  end

  describe UInt128 do
    it "converts from Python" do
      Crython.session do
        pyobject = 340282366920938463463374607431768211455_u128.to_py
        UInt128.new(pyobject).should eq(340282366920938463463374607431768211455_u128)
      end
    end
  end

  describe Int128 do
    it "converts from Python" do
      Crython.session do
        pyobject = (-170141183460469231731687303715884105728_i128).to_py
        Int128.new(pyobject).should eq(-170141183460469231731687303715884105728_i128)
      end
    end
  end

  describe Float32 do
    it "converts from Python" do
      Crython.session do
        pyobject = 3.14.to_py
        Float32.new(pyobject).should eq(3.14.to_f32)
      end
    end
  end

  describe Float64 do
    it "converts from Python" do
      Crython.session do
        pyobject = 3.14.to_py
        Float64.new(pyobject).should eq(3.14)
      end
    end
  end
end
