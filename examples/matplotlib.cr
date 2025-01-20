require "../src/crython"

Crython.embed_python do
  plt = Crython.import_module("matplotlib.pyplot")
  attr = plt.get_attr("subplots")
  ret = LibPython.obj_call_function(attr, nil)
  fig = LibPython.tuple_get(ret, 0)
  ax = Crython::PyObject.new(LibPython.tuple_get(ret, 1))
  fruits = LibPython.build_value("[s,s,s,s]", "apple", "blueberry", "cherry", "orange")
  counts = LibPython.build_value("[i,i,i,i]", 40, 100, 30, 55)
  bar_labels = LibPython.build_value("[s,s,s,s]", "red", "blue", "_red", "orange")
  bar_colors = LibPython.build_value("[s,s,s,s]", "tab:red", "tab:blue", "tab:red", "tab:orange")
  attr = ax.get_attr("bar")
  args = LibPython.build_value("OO", fruits, counts)
  kwargs = LibPython.build_value("{s:O,s:O}", "label", bar_labels, "color", bar_colors)
  LibPython.obj_call(attr, args, kwargs)
  attr = plt.get_attr("show")
  LibPython.obj_call_function(attr, nil)
end
