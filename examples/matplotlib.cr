require "../src/crython"
require "../src/crython/array"
require "../src/crython/number"
require "../src/crython/string"

Crython.embed_python do
  plt = Crython.import_module("matplotlib.pyplot")
  ret = plt.subplots
  fig = LibPython.tuple_get_item(ret, 0)
  ax = Crython::PyObject.new(LibPython.tuple_get_item(ret, 1))
  fruits = ["apple", "blueberry", "cherry", "orange"].to_py
  counts = [40, 100, 30, 55].to_py
  bar_labels = ["red", "blue", "_red", "orange"].to_py
  bar_colors = ["tab:red", "tab:blue", "tab:red", "tab:orange"].to_py
  ax.bar(fruits, counts, label: bar_labels, color: bar_colors)
  plt.show
end
