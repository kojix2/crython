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

  describe Bool do
    it "converts from Python" do
      Crython.session do
        py_true = true.to_py
        Bool.new(py_true).should eq(true)
        py_false = false.to_py
        Bool.new(py_false).should eq(false)
      end
    end

    it "to_cr" do
      Crython.session do
        py_true = true.to_py
        py_false = false.to_py
        py_true.to_cr.should eq(true)
        py_false.to_cr.should eq(false)
      end
    end
  end

  describe Nil do
    it "converts from Python" do
      Crython.session do
        pyobject = nil.to_py
        Nil.new(pyobject).should eq(nil)
      end
    end

    it "to_cr" do
      Crython.session do
        pyobject = nil.to_py
        pyobject.to_cr.should eq(nil)
      end
    end
  end

  describe Complex do
    it "converts from Python" do
      Crython.session do
        pyobject = Complex.new(3.14, 2.71).to_py
        Complex.new(pyobject).should eq(Complex.new(3.14, 2.71))
      end
    end
  end

  describe "to_cr method" do
    it "converts Python int to Crystal Int64" do
      Crython.session do
        pyobject = 42.to_py
        pyobject.to_cr.should eq(42)
        pyobject.to_cr.should be_a(Int64)
      end
    end

    it "converts Python float to Crystal Float64" do
      Crython.session do
        pyobject = 3.14.to_py
        pyobject.to_cr.should eq(3.14)
        pyobject.to_cr.should be_a(Float64)
      end
    end

    it "converts Python str to Crystal String" do
      Crython.session do
        pyobject = "hello".to_py
        pyobject.to_cr.should eq("hello")
        pyobject.to_cr.should be_a(String)
      end
    end

    it "converts Python bool to Crystal Bool" do
      Crython.session do
        py_true = true.to_py
        py_false = false.to_py
        py_true.to_cr.should eq(true)
        py_true.to_cr.should be_a(Bool)
        py_false.to_cr.should eq(false)
        py_false.to_cr.should be_a(Bool)
      end
    end

    it "converts Python None to Crystal nil" do
      Crython.session do
        pyobject = nil.to_py
        pyobject.to_cr.should eq(nil)
        pyobject.to_cr.should be_a(Nil)
      end
    end

    it "converts Python list to Crystal Array(PyObject)" do
      Crython.session do
        pyobject = [1, 2, 3].to_py
        result = pyobject.to_cr
        result.should be_a(Array(Crython::PyObject))
        array = result.as(Array(Crython::PyObject))
        array.size.should eq(3)
        array[0].to_cr.should eq(1)
        array[1].to_cr.should eq(2)
        array[2].to_cr.should eq(3)
      end
    end

    it "converts Python tuple to Crystal Array(PyObject)" do
      Crython.session do
        # Create a Python tuple
        py_code = "import sys; sys.modules['__main__'].__dict__['result'] = (1, 2, 3)"
        Crython.exec(py_code)
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        result = pyobject.to_cr
        result.should be_a(Array(Crython::PyObject))
        array = result.as(Array(Crython::PyObject))
        array.size.should eq(3)
        array[0].to_cr.should eq(1)
        array[1].to_cr.should eq(2)
        array[2].to_cr.should eq(3)
      end
    end

    it "converts Python dict to Crystal Hash(PyObject, PyObject)" do
      Crython.session do
        # Create a Python dict
        py_code = "import sys; sys.modules['__main__'].__dict__['result'] = {'a': 1, 'b': 2, 'c': 3}"
        Crython.exec(py_code)
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        result = pyobject.to_cr
        result.should be_a(Hash(Crython::PyObject, Crython::PyObject))
        hash = result.as(Hash(Crython::PyObject, Crython::PyObject))
        hash.size.should eq(3)

        # Get keys and convert them to strings for comparison
        keys = hash.keys.map { |k| k.to_cr.as(String) }.sort
        keys.should eq(["a", "b", "c"])

        # Check values
        values = hash.values.map { |v| v.to_cr.as(Int64) }.sort
        values.should eq([1, 2, 3])
      end
    end

    it "converts Python complex to Crystal Complex" do
      Crython.session do
        # Create a Python complex
        py_code = "import sys; sys.modules['__main__'].__dict__['result'] = complex(3.14, 2.71)"
        Crython.exec(py_code)
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        result = pyobject.to_cr
        result.should be_a(Complex)
        complex = result.as(Complex)
        complex.real.should be_close(3.14, 0.0001)
        complex.imag.should be_close(2.71, 0.0001)
      end
    end

    it "handles large integers with overflow check" do
      Crython.session do
        # Create a Python int that's large but within Int64 range
        py_code = "import sys; sys.modules['__main__'].__dict__['result'] = 2**60"
        Crython.exec(py_code)
        sys = Crython.import("sys")
        main_dict = sys.modules["__main__"].__dict__
        pyobject = main_dict["result"]

        # Should convert to Int64 via string representation
        result = pyobject.to_cr
        result.should be_a(Int64)
        int = result.as(Int64)
        int.should eq(2_i64**60)
      end
    end
  end

  # describe Symbol do
  #   it "converts from Python" do
  #     Crython.session do
  #       pyobject = :hello.to_py
  #       expect_raises(RuntimeError) do
  #         Symbol.new(pyobject)
  #       end
  #     end
  #   end
  # end

  describe String do
    it "converts from Python" do
      Crython.session do
        pyobject = "Hello, World!".to_py
        String.new(pyobject).should eq("Hello, World!")
      end
    end
  end

  describe Char do
    it "converts from Python" do
      Crython.session do
        pyobject = '@'.to_py
        Char.new(pyobject).should eq('@')
      end
    end
  end

  describe Array do
    it "converts from Python" do
      Crython.session do
        pyobject = [1, 2, 3].to_py
        Array(Int32).new(pyobject).should eq([1, 2, 3])
      end
    end

    # it "converts from Python with different types" do
    #   Crython.session do
    #     pyobject = [1, 2.0, "3"].to_py
    #     Array(Int32 | Float64 | String).new(pyobject).should eq([1, 2.0, "3"])
    #   end
    # end

    it "converts from Python with nested arrays" do
      Crython.session do
        pyobject = [[1, 2], [3, 4], [5, 6]].to_py
        Array(Array(Int32)).new(pyobject).should eq([[1, 2], [3, 4], [5, 6]])
      end
    end
  end

  describe Hash do
    it "converts from Python" do
      Crython.session do
        pyobject = {"a" => 1, "b" => 2, "c" => 3}.to_h.to_py
        Hash(String, Int32).new(pyobject).should eq({"a" => 1, "b" => 2, "c" => 3})
      end
    end

    # it "converts from Python with different types" do
    #   Crython.session do
    #     pyobject = {a: 1, b: 2.0, c: "3"}.to_py
    #     Hash(Symbol, Int32 | Float64 | String).new(pyobject).should eq({a: 1, b: 2.0, c: "3"})
    #   end
    # end
  end
end
