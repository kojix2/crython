require "../../src/crython"

Crython.embed_python do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "whitegrid")
  iris = sns.load_dataset("iris")

  # "Melt" the dataset to "long-form" or "tidy" representation
  iris = iris.melt(id_vars: "species", var_name: "measurement")

  # Initialize the figure
  f, ax = plt.subplots
  sns.despine(bottom: true, left: true)

  # Show each observation with a scatterplot
  sns.stripplot(
    data: iris, x: "value", y: "measurement", hue: "species",
    dodge: true, alpha: 0.25, zorder: 1, legend: false,
  )

  # Show the conditional means, aligning each pointplot in the
  # center of the strips by adjusting the width allotted to each
  # category (.8 by default) by the number of hue levels
  sns.pointplot(
    data: iris, x: "value", y: "measurement", hue: "species",
    dodge: 0.8 - 0.8 / 3, palette: "dark", errorbar: nil,
    markers: "d", markersize: 4, linestyle: "none",
  )

  # Improve the legend
  sns.move_legend(
    ax, loc: "lower right", ncol: 3, frameon: true, columnspacing: 1, handletextpad: 0)

  plt.show
end
