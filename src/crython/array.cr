class Array(T)
  def to_py
    list = LibPython.list_new(self.size)
    self.each_with_index do |item, index|
      LibPython.list_set_item(list, index, item.to_py)
    end
    list
  end
end
