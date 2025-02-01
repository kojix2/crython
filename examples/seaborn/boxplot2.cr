require "../../src/crython"

Crython.embed_python do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "ticks")

  # Initialize the figure with a logarithmic x axis
  f, ax = plt.subplots(figsize: [7, 6])
  ax.set_xscale("log")

  # Load the example planets dataset
  planets = sns.load_dataset("planets")

  # Plot the orbital period with horizontal boxes
  sns.boxplot(
    planets, x: "distance", y: "method", hue: "method",
    whis: [0, 100], width: 0.6, palette: "vlag"
  )

  # Add in points to show each observation
  sns.stripplot(planets, x: "distance", y: "method", size: 4, color: ".3")

  # Tweak the visual presentation
  ax.xaxis.grid(true)
  ax.set(ylabel: "")
  sns.despine(trim: true, left: true)

  plt.show
end
