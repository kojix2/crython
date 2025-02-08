require "../../src/crython"

Crython.session do
  sns = Crython.import("seaborn")
  sns.set_theme(style: "whitegrid")

  # Load the example planets dataset
  planets = sns.load_dataset("planets")

  cmap = sns.cubehelix_palette(rot: -0.2, as_cmap: true)
  g = sns.relplot(
    data: planets,
    x: "distance", y: "orbital_period",
    hue: "year", size: "mass",
    palette: cmap, sizes: {10, 200},
  )
  g.set(xscale: "log", yscale: "log")
  g.ax.xaxis.grid(true, "minor", linewidth: 0.25)
  g.ax.yaxis.grid(true, "minor", linewidth: 0.25)
  g.despine(left: true, bottom: true)

  plt = Crython.import("matplotlib.pyplot")
  plt.show
end
