class String
  def to_py
    LibPython.unicode_from_string_and_size(self.to_unsafe, self.size)
  end
end
