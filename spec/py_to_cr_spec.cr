require "./spec_helper"

describe Number do
  describe UInt8 do
    it "converts to Crystal" do
      Crython.embed_python do
        py_uint8 = 255_u8.to_py
        py_uint8.should be_a(Crython::PyObject)
        py_uint8.to_s.should eq("255")
        py_uint8.to_cr.should eq(255)
      end
    end
  end
end
