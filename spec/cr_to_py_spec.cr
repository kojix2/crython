require "./spec_helper"

describe Number do
  describe UInt8 do
    it "converts to Python" do
      Crython.session do
        py_uint8 = 255_u8.to_py
        py_uint8.should be_a(Crython::PyObject)
        py_uint8.to_s.should eq("255")
      end
    end
  end

  describe Int8 do
    it "converts to Python" do
      Crython.session do
        py_int8 = -128_i8.to_py
        py_int8.should be_a(Crython::PyObject)
        py_int8.to_s.should eq("-128")
      end
    end
  end

  describe UInt16 do
    it "converts to Python" do
      Crython.session do
        py_uint16 = 65535_u16.to_py
        py_uint16.should be_a(Crython::PyObject)
        py_uint16.to_s.should eq("65535")
      end
    end
  end

  describe Int16 do
    it "converts to Python" do
      Crython.session do
        py_int16 = -32768_i16.to_py
        py_int16.should be_a(Crython::PyObject)
        py_int16.to_s.should eq("-32768")
      end
    end
  end

  describe UInt32 do
    it "converts to Python" do
      Crython.session do
        py_uint32 = 4294967295_u32.to_py
        py_uint32.should be_a(Crython::PyObject)
        py_uint32.to_s.should eq("4294967295")
      end
    end
  end

  describe Int32 do
    it "converts to Python" do
      Crython.session do
        py_int32 = -2147483648_i32.to_py
        py_int32.should be_a(Crython::PyObject)
        py_int32.to_s.should eq("-2147483648")
      end
    end
  end

  describe UInt64 do
    it "converts to Python" do
      Crython.session do
        py_uint64 = 18446744073709551615_u64.to_py
        py_uint64.should be_a(Crython::PyObject)
        py_uint64.to_s.should eq("18446744073709551615")
      end
    end
  end

  describe Int64 do
    it "converts to Python" do
      Crython.session do
        py_int64 = -9223372036854775808_i64.to_py
        py_int64.should be_a(Crython::PyObject)
        py_int64.to_s.should eq("-9223372036854775808")
      end
    end
  end

  describe UInt128 do
    it "converts to Python" do
      Crython.session do
        py_uint128 = 340282366920938463463374607431768211455_u128.to_py
        py_uint128.should be_a(Crython::PyObject)
        py_uint128.to_s.should eq("340282366920938463463374607431768211455")
      end
    end
  end

  describe Int128 do
    it "converts to Python" do
      Crython.session do
        py_int128 = -170141183460469231731687303715884105728_i128.to_py
        py_int128.should be_a(Crython::PyObject)
        py_int128.to_s.should eq("-170141183460469231731687303715884105728")
      end
    end
  end

  describe Float32 do
    it "converts to Python" do
      Crython.session do
        py_float32 = 3.4028234663852886e+38_f32.to_py
        py_float32.should be_a(Crython::PyObject)
        py_float32.to_s.should eq("3.4028234663852886e+38")
      end
    end
  end

  describe Float64 do
    it "converts to Python" do
      Crython.session do
        py_float64 = 1.7976931348623157e+308_f64.to_py
        py_float64.should be_a(Crython::PyObject)
        py_float64.to_s.should eq("1.7976931348623157e+308")
      end
    end
  end

  describe Complex do
    it "converts to Python" do
      Crython.session do
        py_complex = Complex.new(1.0, 2.0).to_py
        py_complex.should be_a(Crython::PyObject)
        py_complex.to_s.should eq("(1+2j)")
      end
    end
  end

  describe String do
    it "converts to Python" do
      Crython.session do
        py_string = "Hello, World!".to_py
        py_string.should be_a(Crython::PyObject)
        py_string.to_s.should eq("Hello, World!")
      end
    end
  end

  describe Tuple do
    it "converts to Python" do
      Crython.session do
        py_tuple = {1, 2, 3}.to_py
        py_tuple.should be_a(Crython::PyObject)
        py_tuple.to_s.should eq("(1, 2, 3)")
      end
    end
  end

  describe Hash do
    it "converts to Python" do
      Crython.session do
        py_dict = {"a" => 1, "b" => 2, "c" => 3}.to_py
        py_dict.should be_a(Crython::PyObject)
        py_dict.to_s.should eq("{'a': 1, 'b': 2, 'c': 3}")
      end
    end

    it "converts a hash with different types to Python" do
      Crython.session do
        py_dict = {"a" => 1, "b" => 2.0, "c" => "3"}.to_py
        py_dict.should be_a(Crython::PyObject)
        py_dict.to_s.should eq("{'a': 1, 'b': 2.0, 'c': '3'}")
      end
    end

    it "converts a hash with nested hashes to Python" do
      Crython.session do
        py_dict = {"a" => {"b" => 1}, "c" => {"d" => 2}, "e" => {"f" => 3}}.to_py
        py_dict.should be_a(Crython::PyObject)
        py_dict.to_s.should eq("{'a': {'b': 1}, 'c': {'d': 2}, 'e': {'f': 3}}")
      end
    end
  end

  describe NamedTuple do
    it "converts to Python" do
      Crython.session do
        py_named_tuple = NamedTuple.new(x: 1, y: 2, z: 3).to_py
        py_named_tuple.should be_a(Crython::PyObject)
        py_named_tuple.to_s.should eq("{'x': 1, 'y': 2, 'z': 3}")
      end
    end
  end

  describe Array do
    it "converts to Python" do
      Crython.session do
        py_array = [1, 2, 3].to_py
        py_array.should be_a(Crython::PyObject)
        py_array.to_s.should eq("[1, 2, 3]")
      end
    end

    it "converts an array of different types to Python" do
      Crython.session do
        py_array = [1, 2.0, "3"].to_py
        py_array.should be_a(Crython::PyObject)
        py_array.to_s.should eq("[1, 2.0, '3']")
      end
    end

    it "converts an array of nested arrays to Python" do
      Crython.session do
        py_array = [[1, 2], [3, 4], [5, 6]].to_py
        py_array.should be_a(Crython::PyObject)
        py_array.to_s.should eq("[[1, 2], [3, 4], [5, 6]]")
      end
    end
  end

  describe Symbol do
    it "converts to Python" do
      Crython.session do
        py_symbol = :symbol.to_py
        py_symbol.should be_a(Crython::PyObject)
        py_symbol.to_s.should eq("symbol")
      end
    end
  end

  describe Bool do
    it "converts true to Python" do
      Crython.session do
        py_true = true.to_py
        py_true.should be_a(Crython::PyObject)
        py_true.to_s.should eq("True")
      end
    end

    it "converts false to Python" do
      Crython.session do
        py_false = false.to_py
        py_false.should be_a(Crython::PyObject)
        py_false.to_s.should eq("False")
      end
    end
  end

  describe Nil do
    it "converts to Python" do
      Crython.session do
        py_nil = nil.to_py
        py_nil.should be_a(Crython::PyObject)
        py_nil.to_s.should eq("None")
      end
    end
  end
end
