require "../src/crython"

# import matplotlib.pyplot as plt

# fig, ax = plt.subplots()

# fruits = ['apple', 'blueberry', 'cherry', 'orange']
# counts = [40, 100, 30, 55]
# bar_labels = ['red', 'blue', '_red', 'orange']
# bar_colors = ['tab:red', 'tab:blue', 'tab:red', 'tab:orange']

# ax.bar(fruits, counts, label=bar_labels, color=bar_colors)

# ax.set_ylabel('fruit supply')
# ax.set_title('Fruit supply by kind and color')
# ax.legend(title='Fruit color')

# plt.show()

Crython.init

plt = Crython.import_module("matplotlib")

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
kwarg = LibPython.build_value("{s:O,s:O}", "label", bar_labels, "color", bar_colors)

LibPython.obj_call(attr, args, kwarg)
attr = ax.get_attr("set_ylabel")

attr = plt.get_attr("show")
LibPython.obj_call_function(attr, nil)


