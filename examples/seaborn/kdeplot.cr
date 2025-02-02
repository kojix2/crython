require "../../src/crython"

Crython.embed_python do
  sns = Crython.import("seaborn")
  plt = Crython.import("matplotlib.pyplot")

  sns.set_theme(style: "darkgrid")
  iris = sns.load_dataset("iris")

  # Set up the figure
  f, ax = plt.subplots(figsize: [8, 8])
  ax.set_aspect("equal")

  # Filter the DataFrame without using query
  filtered_iris = iris[iris["species"] != "versicolor"]

  # Draw a contour plot to represent each bivariate density
  sns.kdeplot(
    data: filtered_iris,
    x: "sepal_width",
    y: "sepal_length",
    hue: "species",
    thresh: 0.1,
  )

  plt.show
end
