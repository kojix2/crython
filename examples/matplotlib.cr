require "../src/crython"

Crython.init
plt = Crython.import("matplotlib.pyplot")
ret = plt.subplots
ax = ret[1]
fruits = ["apple", "blueberry", "cherry", "orange"]
counts = [40, 100, 30, 55]
bar_labels = ["red", "blue", "_red", "orange"]
bar_colors = ["tab:red", "tab:blue", "tab:red", "tab:orange"]
ax.bar(fruits, counts, label: bar_labels, color: bar_colors)
plt.show
